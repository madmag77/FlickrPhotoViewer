//
//  PhotoViewerPresenter.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import Foundation

protocol PopupDisplay {
    func showPopup(with message: String)
}

protocol PhotoViewerPresenter {
    func viewDidLoad()
    func itemsCount() -> Int
    func configureItem(_ item: PhotoCellItem, with indexPath: IndexPath)
    func changeSearchString(to string: String)
}

class PhotoViewerPresenterImpl {
    var interactor: PhotoViewerInteractor?
    weak var view: PhotoViewerView?
    var dataStore: PhotoViewerDataStoreReader?
    var popupDisplay: PopupDisplay?
    var searchStringHandler: SearchStringHandler?
    
    private let startAppSearchSstring = "unsorted"
}

extension PhotoViewerPresenterImpl: PhotoViewerPresenter {
    func viewDidLoad() {
        // Just to show something at first start
        // change to another API call e.g. method.recent 
        interactor?.photoSearch(with: startAppSearchSstring)
    }
    
    func itemsCount() -> Int {
        return dataStore?.itemsCount() ?? 0
    }
    
    func configureItem(_ item: PhotoCellItem, with indexPath: IndexPath) {
       guard let dataStore = dataStore,
        let title = dataStore.item(for: indexPath.row).title else {
            return
        }
        
        item.setTitle(title)
    }
    
    func changeSearchString(to string: String) {
        searchStringHandler?.stringChanged(to: string)
    }

}

extension PhotoViewerPresenterImpl: PhotoViewerInteractorDelegate {
    func errorOccured(_ error: Error) {
        popupDisplay?.showPopup(with: error.localizedDescription)
    }
}

extension PhotoViewerPresenterImpl: PhotoViewerDataStoreDelegate {
    func dataWasChanged() {
        DispatchQueue.main.async {
            self.view?.updatePhotosView()
        }
    }
    
    func requestPage(with number: Int) {
        interactor?.photoSearch(with: searchStringHandler?.searchString ?? startAppSearchSstring, page: number)
    }
}

extension PhotoViewerPresenterImpl: SearchStringHandlerDelegate {
    func canSearchString(_ string: String) {
         interactor?.photoSearch(with: string)
    }
    
    
}
