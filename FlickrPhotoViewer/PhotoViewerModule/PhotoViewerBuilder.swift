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
        
        let dataSource = PhotoViewerDataStore()
        let photoSearchService = PhotoSearchFlickrWebService()
        let interactor = PhotoViewerInteractorImpl(photoSearchService: photoSearchService)
        
        let presenter = PhotoViewerPresenterImpl()
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
