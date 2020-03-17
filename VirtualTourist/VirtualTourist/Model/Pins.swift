//
//  Pin.swift
//  VirtualTourist
//
//  Created by Kyle Wilson on 2020-03-16.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import Foundation
import MapKit

class Pins: MKPointAnnotation {
    var pin: Pin

    init(pin: Pin){
        self.pin = pin
        super.init()
        self.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
    }
}
