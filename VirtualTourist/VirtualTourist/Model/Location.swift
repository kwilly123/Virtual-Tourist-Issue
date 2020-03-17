//
//  Location.swift
//  VirtualTourist
//
//  Created by Kyle Wilson on 2020-03-16.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import Foundation

struct Location: Codable {
    let latitude: Double
    let longitude: Double
    let location: String
    let country: String
    
    enum CodingKeys: String, CodingKey {
        case location
        case country
        case latitude
        case longitude
    }
}
