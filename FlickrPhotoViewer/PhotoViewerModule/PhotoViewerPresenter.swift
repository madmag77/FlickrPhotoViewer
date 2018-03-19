//
//  PhotoViewerPresenter.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import Foundation

protocol PhotoViewerPresenter {
    func viewDidLoad()
    func itemsCount() -> Int
    func configureItem(_ item: PhotoCellItem, with indexPath: IndexPath)
    func searchStringWasChanged(to string: String)
}

class PhotoViewerPresenterImpl {
    var interactor: PhotoViewerInteractor?
    weak var view: PhotoViewerView?
    var dataStore: PhotoViewerDataStoreReader?
    private var searchStringHandler: SearchStringHandler?
    
    private let startAppSearchString = "unsorted"
    
    init(searchStringHandler: SearchStringHandler?) {
        self.searchStringHandler = searchStringHandler
        self.searchStringHandler?.delegate = self
    }
    
    // We want to fetch data for string that user searchs or for default one if it's first start
    private func fetchData(page: Int = 1) {
        DispatchQueue.main.async {
            self.view?.showLoadingState()
        }
        let searchString = searchStringHandler?.searchString ?? startAppSearchString
        interactor?.searchPhotos(with: searchString, page: page)
    }
}

extension PhotoViewerPresenterImpl: PhotoViewerPresenter {
    func viewDidLoad() {
        // Just to show something at first start
        // TODO: change to another API call e.g. method.recent
        self.fetchData()
    }
    
    func itemsCount() -> Int {
        return dataStore?.itemsCount() ?? 0
    }
    
    func configureItem(_ item: PhotoCellItem, with indexPath: IndexPath) {
        guard let dataStore = dataStore else { return }
        let (title, image) = dataStore.item(for: indexPath.row)
        if let title = title {
            item.setTitle(title)
        }
        
        if let image = image {
            item.setPhoto(image)
        }
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
    
    func requestPage(with number: Int) {
        fetchData(page: number)
    }
    
    func photoDownloaded(for index: Int) {
         DispatchQueue.main.async {
            self.view?.updatePhoto(with: index)
        }
    }
}

extension PhotoViewerPresenterImpl: SearchStringHandlerDelegate {
    func canSearchString(_ string: String) {
        fetchData()
    }
}
