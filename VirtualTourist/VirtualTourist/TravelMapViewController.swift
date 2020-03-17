//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Kyle Wilson on 2020-03-09.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelMapViewController: UIViewController {
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var pin: Pin?
    let regionKey: String = "persistedMapRegion"
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callPersistedLocation()
        mapView.delegate = self
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc func longTap(sender: UIGestureRecognizer) {
        if sender.state == .ended {
            let locationTappedInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationTappedInView, toCoordinateFrom: mapView)
            saveGeoCoordination(from: locationOnMap)
        }
    }
    
    func copyLocation(_ annotation: MKPointAnnotation) {
//        let location = Pin(context: dataController.viewContext)
//        location.creationDate = Date()
//        location.longitude = annotation.coordinate.longitude
//        location.latitude = annotation.coordinate.latitude
//        location.locationName = annotation.title
//        location.country = annotation.subtitle
//        location.pages = 0
//        try? dataController.viewContext.save()
//        let annotationPin = Pins(pin: location)
//        self.mapView.addAnnotation(annotationPin)
        
    }
    
    func saveGeoCoordination(from coordinate: CLLocationCoordinate2D) {
        let geoPos = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let annotation = MKPointAnnotation()
        CLGeocoder().reverseGeocodeLocation(geoPos) { (placemarks, error) in
            guard let placemark = placemarks?.first else { return }
            annotation.title = placemark.name ?? "Not Known"
            annotation.subtitle = placemark.country
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let photoCollectionViewController = segue.destination as? CollectionViewController else { return }
        let pin: Pins = sender as! Pins
        photoCollectionViewController.pin = pin.pin
        photoCollectionViewController.dataController = dataController
    }
    
    
}

extension TravelMapViewController: MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.animatesDrop = true
            pinView?.tintColor = .black
            pinView?.pinTintColor = .blue
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Tapped PIN")
        let vc = storyboard?.instantiateViewController(identifier: "CollectionViewController") as! CollectionViewController
        performSegue(withIdentifier: "SendLocation", sender: pin)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func reloadData() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        dataController.viewContext.perform {
            do {
                let pins = try self.dataController.viewContext.fetch(request)
                self.mapView.addAnnotations(pins.map { pin in Pins(pin: pin) })
            } catch {
                print("Error fetching pins: \(error)")
            }
        }
        
        
    }
    
    func callPersistedLocation() {
        if let mapRegin = UserDefaults.standard.dictionary(forKey: regionKey) {
            let location = mapRegin as! [String: CLLocationDegrees]
            let center = CLLocationCoordinate2D(latitude: location["latitude"]!, longitude: location["longitude"]!)
            let span = MKCoordinateSpan(latitudeDelta: location["latitudeDelta"]!, longitudeDelta: location["longitudeDelta"]!)
            
            mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
        }
    }
}

