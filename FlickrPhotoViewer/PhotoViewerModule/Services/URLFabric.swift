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
    // Method should obviously added later when we use this URL, but here we have only one method - so it's ok
    private let defaultParams = "method=flickr.photos.search&api_key=&format=json&nojsoncallback=1&safe_search=1"
    private let apiKey = "3e7cc266ae2b0e0d78e279ce8e361736"
    var url: URL {
        return URL(string: "https://api.flickr.com/services/rest/?" + defaultParams + "&api_key=" + apiKey)!
    }
    
}
