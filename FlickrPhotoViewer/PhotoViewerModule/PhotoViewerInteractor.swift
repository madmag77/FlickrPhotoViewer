//
//  PhotoViewerInteractor.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import Foundation

protocol PhotoViewerInteractorDelegate: class {
    
}

protocol PhotoViewerInteractor {
    func photoSearch(with phrase: String)
}

class PhotoViewerInteractorImpl: PhotoViewerInteractor {
    weak var delegate: PhotoViewerInteractorDelegate?
    var photoSearchService: PhotoSearchService?
    
    init(photoSearchService: PhotoSearchService?) {
        self.photoSearchService = photoSearchService
        self.photoSearchService?.delegate = self
    }
    
    func photoSearch(with phrase: String) {
        photoSearchService?.searchPhotos(with: phrase, page: 1)
    }
    
}

extension PhotoViewerInteractorImpl: PhotoSearchServiceDelegate {
    
    func photosFound(_ photos: [RemotePhotoModel]) {
        
    }
    
    func errorOccured(_ error: Error) {
        
    }
    
}
