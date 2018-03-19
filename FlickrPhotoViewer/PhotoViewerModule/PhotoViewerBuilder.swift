//
//  PhotoViewerBuilder.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit

struct PhotoViewerBuilder {
    struct defaults {
        // Flickr default value of photos by page
        static let photosByPage = 100
        
        // Delay between last symbol user entered and API call with this symbol
        static let searchSymbolsDelay = 500
    }
    
    func buildDefaultModule() -> UIViewController {
        let storyboard = UIStoryboard.init(name: "Main",
                                           bundle: nil)
        
        let view = storyboard.instantiateViewController(withIdentifier: "PhotoViewerViewController") as! PhotoViewerViewController
        
        let photoDownloadService = PhotoDownloadFlickrWebService(urlBuilder: FlickrUrlBuilder())
        let dataSource = PhotoViewerDataStore(photoDownloadService: photoDownloadService,
                                              photosPerPage: defaults.photosByPage)
        
        let photoSearchService = PhotoSearchFlickrWebService(urlFabric: FlickrUrlFabric(),
                                                             parser: FlickrParserImpl())
        
        let interactor = PhotoViewerInteractorImpl(photoSearchService: photoSearchService)
        
        let searchStringHandler = SearchStringDelayedHandler(delayInMs: defaults.searchSymbolsDelay)
        let presenter = PhotoViewerPresenterImpl(searchStringHandler: searchStringHandler)
        presenter.view = view
        presenter.interactor = interactor
        presenter.dataStore = dataSource
        dataSource.delegate = presenter
        
        view.output = presenter
        interactor.delegate = presenter
        interactor.dataStore = dataSource
        
        return view
    }
}
