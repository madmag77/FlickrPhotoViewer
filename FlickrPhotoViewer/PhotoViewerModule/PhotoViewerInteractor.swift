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
    func dataLoaded()
}

protocol PhotoViewerInteractor {
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
    
    func photoSearch(with phrase: String, page: Int) {
        guard phrase.count > 0 else {
            dataStore?.clearAll()
            delegate?.dataLoaded()
            return
        }
        
        if page == 1 {
            dataStore?.clearAll()
        }
        
        photoSearchService?.searchPhotos(with: phrase, page: page)
    }

}

extension PhotoViewerInteractorImpl: PhotoSearchServiceDelegate {
    
    func photosFound(_ photos: [RemotePhotoModel]) {
        dataStore?.addModels(photos)
        delegate?.dataLoaded()
    }
    
    func errorOccured(_ error: Error) {
        delegate?.errorOccured(error)
    }
    
}
