//
//  PhotoCache.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 25/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit

protocol PhotoCacheNotificationsDelegate: class {
    func justGotPhoto(for id: String)
}

protocol PhotoCacheReader {
    var delegate: PhotoCacheNotificationsDelegate? {get set}
    func photo(for itemId: String) -> () -> UIImage? 
}

protocol PhotoCacheWriter {
    func setPhoto(_ image: UIImage, for itemId: String)
    func clearCache()
}

class PhotoCacheInMemory {
    var delegate: PhotoCacheNotificationsDelegate?
    
    // Sure thing it's not good to store maybe thousands of images in memory
    // so memory cache should be limited, and persistent file cache introduced
    // TODO: Make separate class - storage with limited storage in memory and big
    // one in FS
    private var imageCache: [String: UIImage] = [:]

    // Since a lot of images are downloading simultaneously
    // we want to make our cache threadsafe with usage of serial queue
    private let cacheQueue = DispatchQueue(label: "CacheQueue")
}

extension PhotoCacheInMemory: PhotoCacheReader {
    func photo(for itemId: String) -> () -> UIImage? {
        return {
                self.cacheQueue.sync {
                    return self.imageCache[itemId]
                }
        }
    }
}

extension PhotoCacheInMemory: PhotoCacheWriter {
    func setPhoto(_ image: UIImage, for itemId: String) {
        cacheQueue.async {
            self.imageCache[itemId] = image
            
            DispatchQueue.global().async {
                self.delegate?.justGotPhoto(for: itemId)
            }
        }
    }
    
    func clearCache() {
        cacheQueue.async {
            self.imageCache = [:]
        }
    }
}
