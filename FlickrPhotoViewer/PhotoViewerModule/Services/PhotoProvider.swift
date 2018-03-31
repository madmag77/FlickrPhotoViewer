//
//  MetaPhotoProvider.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 31/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit

protocol PhotoProviderDelegate: class {
    func photoChanged(for id: String)
    func errorOccured(_ error: Error)
}

protocol PhotoProvider {
    weak var delegate: PhotoProviderDelegate? {get set}
    
    func downloadPhotos(for models: [RemotePhotoModel])
    func photo(for id: String) -> UIImage?
    func clearPhotos()
}

class PhotoProviderImpl : PhotoProvider {
    private var photoDownloadService: PhotoDownloadService?
    private var photoCache: PhotoCache?
    
    weak var delegate: PhotoProviderDelegate?
        
    private func clearAll() {
        photoCache?.clearCache()
    }
    
    init(photoDownloadService: PhotoDownloadService?,
         photoCache: PhotoCache?) {
        self.photoDownloadService = photoDownloadService
        self.photoCache = photoCache
        self.photoDownloadService?.delegate = self
    }

    func downloadPhotos(for models: [RemotePhotoModel]) {
        models.forEach { (model) in
            photoDownloadService?.downloadPhoto(for: model)
        }
    }
    
    func photo(for id: String) -> UIImage? {
        return photoCache?.photo(for: id)()
    }
    
    func clearPhotos() {
        photoCache?.clearCache()
    }
}

extension PhotoProviderImpl: PhotoDownloadServiceDelegate {
    func justDownloadedImage(_ image: UIImage, for id: String) {
        photoCache?.setPhoto(image, for: id)
        delegate?.photoChanged(for: id)
    }
    
    func errorOccured(_ error: Error) {
        delegate?.errorOccured(error)
    }
}

