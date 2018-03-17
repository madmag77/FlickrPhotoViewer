//
//  PhotoSearchService.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import Foundation

protocol PhotoSearchServiceDelegate: class {
    func photosFound(_ photos: [RemotePhotoModel])
    func errorOccured(_ error: Error)
}

protocol PhotoSearchService {
    var delegate: PhotoSearchServiceDelegate? {set get}
    func searchPhotos(with phrase: String, page: Int)
}

class PhotoSearchFlickrWebService: PhotoSearchService {
    weak var delegate: PhotoSearchServiceDelegate?
        
    func searchPhotos(with phrase: String, page: Int) {
        let photosStub = [
            RemotePhotoModel(id: "id111", farm: 1, server: "server", secret: "secret", title: "Title1"),
            RemotePhotoModel(id: "id112", farm: 1, server: "server", secret: "secret", title: "Title2"),
            RemotePhotoModel(id: "id113", farm: 1, server: "server", secret: "secret", title: "Title3"),
            RemotePhotoModel(id: "id114", farm: 1, server: "server", secret: "secret", title: "Title4"),
        ]
        
        DispatchQueue.main.async {
            self.delegate?.photosFound(photosStub)
        }
    }
}
