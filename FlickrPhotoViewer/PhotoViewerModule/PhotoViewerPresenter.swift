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
}

class PhotoViewerPresenterImpl {
    var interactor: PhotoViewerInteractor?
    weak var view: PhotoViewerView?
    var dataStore: PhotoViewerDataStoreReader?
    var popupDisplay: PopupDisplay?
    
}

extension PhotoViewerPresenterImpl: PhotoViewerPresenter {
    func viewDidLoad() {
        interactor?.photoSearch(with: "")
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
}

extension PhotoViewerPresenterImpl: PhotoViewerInteractorDelegate {
    func errorOccured(_ error: Error) {
        popupDisplay?.showPopup(with: error.localizedDescription)
    }
}

extension PhotoViewerPresenterImpl: PhotoViewerDataStoreDelegate {
    func dataWasChanged() {
        view?.updatePhotosView()
    }
    
}
