//
//  PhotoViewerDataStore.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit

// For presenter in order to read from DS
protocol PhotoViewerDataStoreReader: class {
    func itemsCount() -> Int
    func item(for index: Int) -> (title: String?, image: UIImage?)
}

// For interacor in order to write from DS
protocol PhotoViewerDataStoreWriter: class {
    func clearAll()
    func addModels(_ models: [RemotePhotoModel])
}

// For presenter in order to have return calls
protocol PhotoViewerDataStoreDelegate: class {
    func dataWasChanged()
    func photoDownloaded(for index: Int)
}

class PhotoViewerDataStore {
    weak var delegate: PhotoViewerDataStoreDelegate?

    private var photoModels: [RemotePhotoModel] = []
    
    // We want to search for index of item in array in order to update photo in
    // definite cell (cells index is the same as index in array)
    private var mapIdToIndex: [String: Int] = [:]
    private var photoCache: PhotoCacheReader?
    
    init(photoCache: PhotoCacheReader?) {
        self.photoCache = photoCache
        self.photoCache?.delegate = self
    }

    private func addIdToIndex(from models: [RemotePhotoModel]) {
        var index = photoModels.count - models.count
        for model in models {
            defer {index += 1}
            mapIdToIndex[model.id] = index
        }
    }
}

extension PhotoViewerDataStore: PhotoViewerDataStoreReader {
    func itemsCount() -> Int {
        return photoModels.count
    }
    
    func item(for index: Int) -> (title: String?, image: UIImage?) {
        guard index < photoModels.count else { return (nil, nil) }
        
        // Check for photo in cache
        let image = photoCache?.photo(for: photoModels[index].id)()
        
        return (photoModels[index].title, image)
    }
}

extension PhotoViewerDataStore: PhotoViewerDataStoreWriter {
    func clearAll() {
        photoModels = []
        mapIdToIndex = [:]
        delegate?.dataWasChanged()
    }
    
    func addModels(_ models: [RemotePhotoModel]) {
        photoModels += models
        addIdToIndex(from: models)
        delegate?.dataWasChanged()
    }
}

extension PhotoViewerDataStore: PhotoCacheNotificationsDelegate {
    // Notice from photo cache about new photo
    func justGotPhoto(for id: String) {
        guard let index = mapIdToIndex[id] else { return }
        
        delegate?.photoDownloaded(for: index)
    }
}
