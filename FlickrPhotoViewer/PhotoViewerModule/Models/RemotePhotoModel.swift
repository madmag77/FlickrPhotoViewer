//
//  RemotePhotoModel.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import Foundation

// https://www.flickr.com/services/api/explore/flickr.photos.search
struct RemotePhotoModel {
    let id: String
    let farm: Int
    let server: String
    let secret: String
    let title: String
}
