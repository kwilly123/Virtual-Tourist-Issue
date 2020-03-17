//
//  FlickrData.swift
//  VirtualTourist
//
//  Created by Kyle Wilson on 2020-03-13.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import Foundation

struct FlickrSearchResponseData: Codable {
    let data: FlickrSearchData
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case data = "photos"
        case status = "stat"
    }
}

/// The search response data returned from the flickr API.
struct FlickrSearchData: Codable {
    let page: Int
    let pages: Int
    let perPage: Int
    let totalPhotoCount: String
    let photos: [FlickrImage]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case totalPhotoCount = "total"
        case photos = "photo"
    }
}

/// The image data returned from the flickr API
struct FlickrImage: Codable {
    let id: String
    let title: String
    let mediumUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case mediumUrl = "url_m"
    }
}
