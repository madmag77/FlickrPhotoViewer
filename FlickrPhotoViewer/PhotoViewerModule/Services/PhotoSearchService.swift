//
//  PhotoSearchService.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import Foundation

class ServerError: Error {
    var localizedDescription = "Server returns error"
}

class SearchInputError: Error {
    var localizedDescription = "Search string is invalid"
}

class ParseError: Error {
    var localizedDescription = "Search returns unreadable data"
}

protocol PhotoSearchServiceDelegate: class {
    func photosFound(_ photos: [RemotePhotoModel])
    func errorOccured(_ error: Error)
}

protocol PhotoSearchService {
    var delegate: PhotoSearchServiceDelegate? {get set}
    func searchPhotos(with phrase: String, page: Int)
}

class PhotoSearchFlickrWebService: PhotoSearchService {
    weak var delegate: PhotoSearchServiceDelegate?
    private let urlSession = URLSession.shared
    private let urlFabric: UrlFabric
    private var photoSearchTask: URLSessionDataTask?
    private let emptySearchStringStub = "unsorted"
    
    init(urlFabric: UrlFabric) {
        self.urlFabric = urlFabric
    }
    
    func searchPhotos(with phrase: String, page: Int) {
        
        // We want to have one more layer under service - like FlickrWebService
        // where all this magic with parameters and serialization/deserialization should happen
        // hopfully with usage of special libraries (e.g. Alamofire + json modeling)
        
        let phraseToSearch = phrase.isEmpty ? emptySearchStringStub : phrase
        guard let urlWithPhrase = URL(string: urlFabric.url.absoluteString + "&text=" + phraseToSearch + "&page=" + String(page)) else {
            self.delegate?.errorOccured(SearchInputError())
            return
        }
        
        photoSearchTask = urlSession.dataTask(with: urlWithPhrase) { (data, response, error) in
            if let error = error {
                self.delegate?.errorOccured(error)
                return
            }
            
            guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200, let data = data else {
                self.delegate?.errorOccured(ServerError())
                    return
            }
            
            guard let objectResponse = try? JSONSerialization.jsonObject(with: data, options: []),
                let photosRootDict = objectResponse as? [String: Any],
                let stat = photosRootDict["stat"] as? String,
                stat != "fail" else {
                    self.delegate?.errorOccured(ServerError())
                    return
            }
            
            guard let photosRoot = photosRootDict["photos"],
                let photoDict = photosRoot as? [String: Any],
                let photos = photoDict["photo"],
                let photosArray = photos as? [NSDictionary] else {
                    self.delegate?.errorOccured(ServerError())
                    return
            }
            
            guard let photoModels = self.deserializePhotosInfo(photosArray) else {
                self.delegate?.errorOccured(ParseError())
                return
            }
            
            self.delegate?.photosFound(photoModels)
            
        }
        
        photoSearchTask?.resume()
        
    }
    
    func deserializePhotosInfo(_ photos:  [NSDictionary]) -> [RemotePhotoModel]? {
        var models: [RemotePhotoModel] = []
        
        for model in photos {
            guard let id = model["id"] as? String,
            let secret = model["secret"] as? String,
            let server = model["server"] as? String,
            let farm = model["farm"] as? Int,
            let title = model["title"] as? String else { return nil }
            
            models.append(RemotePhotoModel(id: id, farm: farm, server: server, secret: secret, title: title))
        }
        
        return models
    }
}
