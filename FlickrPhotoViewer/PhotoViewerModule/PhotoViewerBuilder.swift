//
//  PhotoViewerBuilder.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit

struct PhotoViewerBuilder {
    func buildDefaultModule() -> UIViewController {
        let storyboard = UIStoryboard.init(name: "Main",
                                           bundle: nil)
        
        let view = storyboard.instantiateViewController(withIdentifier: "PhotoViewerViewController") as! PhotoViewerViewController
        
        let photoDownloadService = PhotoDownloadFlickrWebService(urlBuilder: FlickrUrlBuilder())
        let dataSource = PhotoViewerDataStore()
        dataSource.photoDownloadService = photoDownloadService
        photoDownloadService.delegate = dataSource
        
        let photoSearchService = PhotoSearchFlickrWebService(urlFabric: FlickrUrlFabric())
        let interactor = PhotoViewerInteractorImpl(photoSearchService: photoSearchService)
        
        let searchStringHandler = SearchStringDelayedHandler(delayInMs: 500)
        let presenter = PhotoViewerPresenterImpl()
        presenter.view = view
        presenter.interactor = interactor
        presenter.dataStore = dataSource
        dataSource.delegate = presenter
        presenter.searchStringHandler = searchStringHandler
        searchStringHandler.delegate = presenter
        
        view.output = presenter
        interactor.delegate = presenter
        interactor.dataStore = dataSource
        
        return view

    }
}
