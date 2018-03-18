//
//  PhotoViewerDataStore.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit

protocol PhotoViewerDataStoreReader: class {
    func itemsCount() -> Int
    func item(for index: Int) -> (title: String?, image: UIImage?)
}

protocol PhotoViewerDataStoreWriter: class {
    func clearAll()
    func addModels(_ models: [RemotePhotoModel])
}

protocol PhotoViewerDataStoreDelegate: class {
    func dataWasChanged()
    func requestPage(with number: Int)
    func photoDownloaded(for index: Int)
}

class PhotoViewerDataStore {
    private let photosPerPage = 100
    private var requestedPage = 1
    
    private var photoModels: [RemotePhotoModel] = []
    private var mapIdToIndex: [String: Int] = [:]
    
    var photoDownloadService: PhotoDownloadService?
    weak var delegate: PhotoViewerDataStoreDelegate?
    
    private func checkPaging(with index: Int) {
        guard index >= photoModels.count - photosPerPage / 2 else { return }
        
        let pageToRequest = Int(ceil(Double(photoModels.count) / Double(photosPerPage) + 1.0))
        if pageToRequest > requestedPage {
            requestedPage = pageToRequest
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
        
        checkPaging(with: index)
        let image = photoDownloadService?.getPhoto(for: photoModels[index])
        return (photoModels[index].title, image)
    }
}

extension PhotoViewerDataStore: PhotoViewerDataStoreWriter {
    func clearAll() {
        requestedPage = 1
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

extension PhotoViewerDataStore: PhotoDownloadServiceDelegate {
    func justDownloadedImage(for id: String) {
        guard let index = mapIdToIndex[id] else { return }
        delegate?.photoDownloaded(for: index)
    }
    
}
