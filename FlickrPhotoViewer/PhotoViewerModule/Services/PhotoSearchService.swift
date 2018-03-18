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
    private let parser: FlickrParser
    
    init(urlFabric: UrlFabric, parser: FlickrParser) {
        self.urlFabric = urlFabric
        self.parser = parser
    }
    
    func searchPhotos(with phrase: String, page: Int) {
        
        // We want to have one more layer under service - like FlickrWebService
        // where all this magic with parameters and serialization/deserialization should happen
        // hopfully with usage of special libraries (e.g. Alamofire + json modeling)
        // TODO: Make one more layer under this service
        
        guard let urlWithPhrase = URL(string: urlFabric.url.absoluteString + "&text=" + phrase + "&page=" + String(page)) else {
            self.delegate?.errorOccured(SearchInputError())
            return
        }
        
        photoSearchTask = urlSession.dataTask(with: urlWithPhrase) { (data, response, error) in
            if let error = error {
                self.delegate?.errorOccured(error)
                return
            }
            
            // Check if server returns not 200
            guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200, let data = data else {
                self.delegate?.errorOccured(ServerError())
                    return
            }
            
            let (parserError, photoModels) = self.parser.parseServerResponse(data: data)
            
            guard parserError == nil else {
                self.delegate?.errorOccured(parserError!)
                return
            }
            
            self.delegate?.photosFound(photoModels)
            
        }
        
        photoSearchTask?.resume()
        
    }
    
}
