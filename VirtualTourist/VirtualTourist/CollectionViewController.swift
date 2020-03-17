//
//  CollectionViewController.swift
//  VirtualTourist
//
//  Created by Kyle Wilson on 2020-03-10.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    var dataController: DataController!
    @IBOutlet weak var addCollection: UIBarButtonItem!
    
    var locationTitle: String?
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isUserInteractionEnabled = false
        
        guard pin != nil else {
            print("Can't load photo album")
            return
        }
//        self.collectionView.register(PhotoViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupPinForMap()
        setupFetchedResultsController()
        flowLayout()
        downloadPhotos()
        collectionView.allowsMultipleSelection = true
        activityIndicator.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    func setupPinForMap() {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        DispatchQueue.main.async {
            self.mapView.addAnnotation(Pins(pin: self.pin))
            self.mapView.setRegion(region, animated: true)
            self.mapView.regionThatFits(region)
        }
    }
    
    func flowLayout() {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let space: CGFloat = 3.0
            let dimension = view.frame.size.width - (2 * space) / 3.0
            flowLayout.minimumInteritemSpacing = space
            flowLayout.minimumLineSpacing = space
            flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        }
    }
    
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "photo")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Fetch could not be performed \(error.localizedDescription)")
        }
    }
    
    func downloadPhotos() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        guard fetchedResultsController.fetchedObjects!.isEmpty else { //if there are no objects
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            return
        }
        
        let pagesCount = Int(self.pin.pages)
        FlickrClient.searchPhotos(lat: pin.latitude, lon: pin.longitude, totalPageAmt: pagesCount) { (photos, pages, error) in
            
            if photos.count > 0 {
                DispatchQueue.main.async {
                    if pagesCount == 0 {
                        self.pin.pages = Int32(Int(pages))
                    }
                    for _ in photos {
                        do {
                            try self.dataController.viewContext.save()
                        } catch {
                            fatalError("Unable to save the photo")
                        }
                    }
                }
            }
            
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
        
    }
    
}

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoViewCell
        let photoData = self.fetchedResultsController.object(at: indexPath)
        if photoData.imageData == nil {
            addCollection.isEnabled = false
            DispatchQueue.global(qos: .background).async {
                if let imageData = try? Data(contentsOf: photoData.imageUrl!) {
                    DispatchQueue.main.async {
                        photoData.imageData = imageData
                        do {
                            try self.dataController.viewContext.save()
                            
                        } catch {
                            print("error in saving image data")
                        }
                        
                        let image = UIImage(data: imageData)!
                        cell.imageView.image = image
                        
                    }
                }
            }
        } else {
            if let imageData = photoData.imageData {
                let image = UIImage(data: imageData)!
                cell.imageView.image = image
            }
        }
        addCollection.isEnabled = true
        return cell
    }
}

extension CollectionViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            self.collectionView.deleteItems(at: [newIndexPath!])
        case .update:
            self.collectionView.reloadItems(at: [newIndexPath!])
        default:
            break
        }
    }
}
