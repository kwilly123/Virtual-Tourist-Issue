//
//  PhotosParser.swift
//  VirtualTourist
//
//  Created by Kyle Wilson on 2020-03-15.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import Foundation

struct PhotosParser: Codable {
    let photos: Photos
}

struct Photos: Codable {
    let pages: Int
    let photo: [PhotosParser]
}

struct PhotoParser: Codable {
    
    let url: String?
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url_n"
        case title
    }
}
