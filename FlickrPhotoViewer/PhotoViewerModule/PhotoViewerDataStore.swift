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
}

class PhotoViewerDataStore {
    var photoModels: [RemotePhotoModel] = []
    weak var delegate: PhotoViewerDataStoreDelegate?
}

extension PhotoViewerDataStore: PhotoViewerDataStoreReader {
    func itemsCount() -> Int {
        return photoModels.count
    }
    
    func item(for index: Int) -> (title: String?, image: UIImage?) {
        guard index < photoModels.count else { return (nil, nil) }
        
        return (photoModels[index].title, nil)
    }
}

extension PhotoViewerDataStore: PhotoViewerDataStoreWriter {
    func clearAll() {
        photoModels = []
        delegate?.dataWasChanged()
    }
    
    func addModels(_ models: [RemotePhotoModel]) {
        photoModels += models
        delegate?.dataWasChanged()
    }

}
