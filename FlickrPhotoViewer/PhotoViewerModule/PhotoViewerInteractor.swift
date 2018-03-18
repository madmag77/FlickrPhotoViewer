//
//  PhotoViewerInteractor.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import Foundation

protocol PhotoViewerInteractorDelegate: class {
    func errorOccured(_ error: Error)
}

protocol PhotoViewerInteractor {
    func photoSearch(with phrase: String)
    func photoSearch(with phrase: String, page: Int)
}

class PhotoViewerInteractorImpl: PhotoViewerInteractor {
    weak var delegate: PhotoViewerInteractorDelegate?
    var photoSearchService: PhotoSearchService?
    weak var dataStore: PhotoViewerDataStoreWriter?

    init(photoSearchService: PhotoSearchService?) {
        self.photoSearchService = photoSearchService
        self.photoSearchService?.delegate = self
    }
    
    func photoSearch(with phrase: String) {
        photoSearchService?.searchPhotos(with: phrase, page: 1)
    }

    func photoSearch(with phrase: String, page: Int) {
        photoSearchService?.searchPhotos(with: phrase, page: page)
    }

}

extension PhotoViewerInteractorImpl: PhotoSearchServiceDelegate {
    
    func photosFound(_ photos: [RemotePhotoModel]) {
        dataStore?.addModels(photos)
    }
    
    func errorOccured(_ error: Error) {
        delegate?.errorOccured(error)
    }
    
}
