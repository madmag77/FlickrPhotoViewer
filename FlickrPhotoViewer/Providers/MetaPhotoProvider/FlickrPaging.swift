//
//  FlickrPaging.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 25/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import Foundation


protocol FlickrPaging {
    func pageToFetchIfAny(showing index: Int, outOf count: Int) -> Int?
    func clearPaging()
}

// Paging is simple - when we reach half a page before end - we need to fetch next page
class FlickrPagingImpl: FlickrPaging {
    private var itemsPerPage: Int
    private var requestedPage = 1

    init(itemsPerPage: Int) {
        self.itemsPerPage = itemsPerPage
    }
    
    func pageToFetchIfAny(showing index: Int, outOf count: Int) -> Int? {
        guard index >= count - itemsPerPage / 2 else { return nil}
        
        let pageToRequest = Int(ceil(Double(count) / Double(itemsPerPage) + 1.0))
        if pageToRequest > requestedPage {
            requestedPage = pageToRequest
            return pageToRequest
        }
        return nil
    }
    
    func clearPaging() {
        requestedPage = 1
    }
}
