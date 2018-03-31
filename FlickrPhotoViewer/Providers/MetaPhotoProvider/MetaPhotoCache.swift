//
//  PhotoCache.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 25/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit

protocol MetaCache {
    func itemsCount() -> () -> Int
    func item(for index: Int) -> () -> RemotePhotoModel?
    func itemIndex(for id: String) -> () -> Int?
    func clear()
    func addModels(_ models: [RemotePhotoModel])
}

class MetaPhotoCacheInMemory {
    private var photoModels: [RemotePhotoModel] = []
    private var photoModelsMap: [String : Int] = [:]
    private let cacheQueue = DispatchQueue(label: "MetaCacheQueue")
    
    private func addIdToIndex(from models: [RemotePhotoModel]) {
        var index = photoModels.count - models.count
        for model in models {
            defer {index += 1}
            photoModelsMap[model.id] = index
        }
    }
}

extension MetaPhotoCacheInMemory: MetaCache {
    func itemsCount() -> () -> Int {
        return {
            self.cacheQueue.sync {
                return self.photoModels.count
            }
        }
    }
    
    func item(for index: Int) -> () -> RemotePhotoModel? {
        return {
            self.cacheQueue.sync {
                return index < self.photoModels.count ? self.photoModels[index] : nil
            }
        }
    }
    
    func itemIndex(for id: String) -> () -> Int? {
        return {
            self.cacheQueue.sync {
                return self.photoModelsMap[id]
            }
        }
    }

    func clear() {
        cacheQueue.sync {
            self.photoModels = []
            self.photoModelsMap = [:]
        }
    }
    
    func addModels(_ models: [RemotePhotoModel]) {
        cacheQueue.sync {
            self.photoModels += models
            addIdToIndex(from: models)
        }
    }
}
