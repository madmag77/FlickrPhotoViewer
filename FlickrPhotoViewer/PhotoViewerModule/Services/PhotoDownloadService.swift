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
}

class PhotoDownloadFlickrWebService: PhotoDownloadService {
    weak var delegate: PhotoDownloadServiceDelegate?
    private let urlSession = URLSession.shared
    private let urlBuilder: UrlBuilder
    
    // Sure thing it's not good to store maybe thousands of images in memory
    // so memory cache should be limited, and persistent file cache introduced
    private var imageCache: [String: UIImage] = [:]
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
            
            // Seems not ideal - maybe it's better to create another queue in order to notify delegate
            DispatchQueue.main.async {
                self.delegate?.justDownloadedImage(for: id)
            }
        }
    }
}
