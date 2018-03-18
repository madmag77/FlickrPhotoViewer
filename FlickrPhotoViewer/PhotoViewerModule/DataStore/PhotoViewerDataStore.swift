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
    func requestPage(with number: Int)
    func photoDownloaded(for index: Int)
}

class PhotoViewerDataStore {
    private let photosPerPage = 100
    private var requestedPage = 1
    
    private var photoModels: [RemotePhotoModel] = []
    
    // We want to search for index of item in array in order to update photo in
    // definite cell (cells index is the same as index in array)
    private var mapIdToIndex: [String: Int] = [:]
    
    private var photoDownloadService: PhotoDownloadService?
    
    weak var delegate: PhotoViewerDataStoreDelegate?
    
    init(photoDownloadService: PhotoDownloadService?) {
        self.photoDownloadService = photoDownloadService
        self.photoDownloadService?.delegate = self
    }
    
    // Paging is simple - when we reach half a page before end - we need to fetch next page
    // TODO: Make paging as separate class and use it from Presenter
    private func checkPaging(with index: Int) {
        guard index >= photoModels.count - photosPerPage / 2 else { return }
        
        let pageToRequest = Int(ceil(Double(photoModels.count) / Double(photosPerPage) + 1.0))
        if pageToRequest > requestedPage {
            requestedPage = pageToRequest
            
            // We don't want to take much time while user scrolling
            DispatchQueue.global().async {
                self.delegate?.requestPage(with: pageToRequest)
            }
        }
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
        
        // Check for paging
        checkPaging(with: index)
        
        // Check for photo - if there is no photo in cache DownloadService will download it
        let image = photoDownloadService?.getPhoto(for: photoModels[index])
        
        return (photoModels[index].title, image)
    }
}

extension PhotoViewerDataStore: PhotoViewerDataStoreWriter {
    func clearAll() {
        requestedPage = 1
        photoModels = []
        mapIdToIndex = [:]
        photoDownloadService?.clearCache()
        delegate?.dataWasChanged()
    }
    
    func addModels(_ models: [RemotePhotoModel]) {
        photoModels += models
        addIdToIndex(from: models)
        delegate?.dataWasChanged()
    }

}

extension PhotoViewerDataStore: PhotoDownloadServiceDelegate {
    // Notice from download service that we asked about image
    // and it's ready now
    func justDownloadedImage(for id: String) {
        guard let index = mapIdToIndex[id] else { return }
        
        delegate?.photoDownloaded(for: index)
    }
    
}
