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
    func searchPhotos(with phrase: String, page: Int)
}

class PhotoViewerInteractorImpl: PhotoViewerInteractor {
    weak var delegate: PhotoViewerInteractorDelegate?
    weak var dataStore: PhotoViewerDataStoreWriter?
    private var photoSearchService: PhotoSearchService?

    init(photoSearchService: PhotoSearchService?) {
        self.photoSearchService = photoSearchService
        self.photoSearchService?.delegate = self
    }
    
    func searchPhotos(with phrase: String, page: Int) {
        // If search string empty it means user want to clear results
        guard phrase.count > 0 else {
            dataStore?.clearAll()
            delegate?.dataLoaded()
            return
        }
        
        // If it is new string - clear previous results
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
