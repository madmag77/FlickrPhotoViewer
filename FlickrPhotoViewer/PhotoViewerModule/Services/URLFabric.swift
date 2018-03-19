//
//  URLFabric.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 18/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import Foundation

protocol UrlFabric {
    var url: URL {get}
}

struct FlickrUrlFabric: UrlFabric {
    // This string should be constructed with Method, but since we have only one method - it's ok
    private let defaultParams = "method=flickr.photos.search&format=json&nojsoncallback=1&safe_search=1"
    private let apiKey = "3e7cc266ae2b0e0d78e279ce8e361736"
    var url: URL {
        return URL(string: "https://api.flickr.com/services/rest/?" + defaultParams + "&api_key=" + apiKey)!
    }
}

protocol UrlBuilder {
    func getUrlToDownloadPhoto(farm: Int, server: String, secret: String, id: String) -> URL
}

struct FlickrUrlBuilder: UrlBuilder {
    func getUrlToDownloadPhoto(farm: Int, server: String, secret: String, id: String) -> URL {
        return URL(string: "https://farm" + String(farm) + ".static.flickr.com/" + server + "/" + id + "_" + secret + ".jpg")!
    }
}
