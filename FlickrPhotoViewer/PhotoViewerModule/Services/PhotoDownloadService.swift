//
//  PhotoDownloadService.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 18/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit

protocol PhotoDownloadServiceDelegate: class {
    func justDownloadedImage(for id: String)
}

protocol PhotoDownloadService {
    var delegate: PhotoDownloadServiceDelegate? {get set}
    func getPhoto(for model: RemotePhotoModel) -> UIImage?
    func clearCache()
}

class PhotoDownloadFlickrWebService: PhotoDownloadService {
    weak var delegate: PhotoDownloadServiceDelegate?
    
    // TODO: Inject session via protocol in order to make this class testable
    private let urlSession = URLSession.shared
    private let urlBuilder: UrlBuilder
    
    // Sure thing it's not good to store maybe thousands of images in memory
    // so memory cache should be limited, and persistent file cache introduced
    // TODO: Make separate class - storage with limited storage in memory and big
    // one in FS
    private var imageCache: [String: UIImage] = [:]
    
    // Since a lot of images are downloading simultaneously
    // we want to make our cache threadsafe with usage of serial queue
    private let cacheQueue = DispatchQueue(label: "CacheQueue")
    
    init(urlBuilder: UrlBuilder) {
        self.urlBuilder = urlBuilder
    }
    
    func getPhoto(for model: RemotePhotoModel) -> UIImage? {
        // Because of synchronisation of the cache this operation may take a bit time
        // (when write operation occured simultaneously)
        if let image = getImageFromCache(for: model.id)() {
            return image
        }
        
        let url = urlBuilder.getUrlToDownloadPhoto(farm: model.farm,
                                                   server: model.server,
                                                   secret: model.secret,
                                                   id: model.id)
        
        urlSession.dataTask(with: url) { (data, response, error) in
            if let _ = error {
                // TODO think how log errors and show to user
                return
            }
            
            guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200, let data = data else {
                    // TODO think how log errors and show to user
                    return
            }
            
            guard let image = UIImage(data: data) else {
                // TODO think how log errors and show to user
                return
            }
            
            self.putImageToCache(for: model.id, image: image)
            
        }.resume()
        
        return nil
    }
    
    func clearCache() {
        // TODO: Would be better to have array of all current download tasks and
        // stop them in this moment
        clearCacheSafely()
    }
    
    private func getImageFromCache(for id: String) -> () -> UIImage? {
        return {
            self.cacheQueue.sync {
                return self.imageCache[id]
            }
        }
    }
    
    private func putImageToCache(for id: String, image: UIImage) {
        cacheQueue.async {
            self.imageCache[id] = image
            
            DispatchQueue.global().async {
                self.delegate?.justDownloadedImage(for: id)
            }
        }
    }
    
    private func clearCacheSafely() {
        cacheQueue.async {
            self.imageCache = [:]
        }
    }
}
