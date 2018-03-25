//
//  PhotoViewerPresenter.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit

protocol PhotoViewerPresenter {
    func viewDidLoad()
    func searchStringWasChanged(to string: String)
    func willDisplayCell(with index: Int, outOf count: Int)
}

class PhotoViewerPresenterImpl {
    var interactor: PhotoViewerInteractor?
    weak var view: PhotoViewerView?
    
    private var searchString: String {
        return searchStringHandler?.searchString ?? startAppSearchString
    }
    private var searchStringHandler: SearchStringHandler?
    private let startAppSearchString = "unsorted"
    
    init(searchStringHandler: SearchStringHandler?) {
        self.searchStringHandler = searchStringHandler
        self.searchStringHandler?.delegate = self
    }

    // We want to fetch data for string that user searchs or for default one if it's first start
    private func searchPhotos(with string: String) {
        DispatchQueue.main.async {
            self.view?.showLoadingState()
        }
        
        if string.count == 0 {
            // Empty string - let's clear search
            interactor?.clearSearch()
        } else {
            interactor?.startSearchingPhotos(with: string)
        }
    }
    
    private func configureItem() -> (_ item: PhotoCellItem, _ title: String?, _ image: UIImage?) -> () {
        return {item, title, image in
            if let title = title {
                item.setTitle(title)
            }
            
            if let image = image {
                item.setPhoto(image)
            }
        }
    }
}

extension PhotoViewerPresenterImpl: PhotoViewerPresenter {
    func viewDidLoad() {
        
        view?.configureCellItem = configureItem()
        
        // Just to show something at first start
        // TODO: change to another API call e.g. method.recent
        self.searchPhotos(with: startAppSearchString)
    }
    
    func willDisplayCell(with index: Int, outOf count: Int) {
        interactor?.updatePaging(with: index, outOf: count, searchString: searchString)
    }
    
    func searchStringWasChanged(to string: String) {
        searchStringHandler?.stringWasChanged(to: string)
    }
}

extension PhotoViewerPresenterImpl: PhotoViewerInteractorDelegate {
    func errorOccured(_ error: Error) {
        DispatchQueue.main.async {
            self.view?.showError(with: error.localizedDescription)            
        }
    }
    
    func dataLoaded() {
        DispatchQueue.main.async {
            self.view?.showLoadedState()
        }
    }
}

extension PhotoViewerPresenterImpl: PhotoViewerDataStoreDelegate {
    func dataWasChanged() {
         DispatchQueue.main.async {
            self.view?.updatePhotosView()
        }
    }
        
    func photoDownloaded(for index: Int) {
         DispatchQueue.main.async {
            self.view?.updatePhoto(with: index)
        }
    }
}

extension PhotoViewerPresenterImpl: SearchStringHandlerDelegate {
    func canSearchString(_ string: String) {
        searchPhotos(with: string)
    }
}
