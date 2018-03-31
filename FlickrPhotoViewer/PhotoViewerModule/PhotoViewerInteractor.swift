//
//  PhotoViewerInteractor.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit

protocol PhotoViewerInteractorDelegate: class {
    func errorOccured(_ error: Error)
    func dataChanged()
    func photoDownloaded(for index: Int)
}

protocol PhotoViewerInteractor {
    func clearSearch()
    func startSearchingPhotos(with phrase: String)
    func itemsCount() -> Int
    func item(for index: Int) -> (title: String?, image: UIImage?)
}

class PhotoViewerInteractorImpl {
    weak var delegate: PhotoViewerInteractorDelegate?
    private var metaPhotoProvider: MetaPhotoProvider?
    private var photoProvider: PhotoProvider?
    
    init(metaPhotoProvider: MetaPhotoProvider?,
         photoProvider: PhotoProvider?) {
        self.metaPhotoProvider = metaPhotoProvider
        self.metaPhotoProvider?.delegate = self
        self.photoProvider = photoProvider
        self.photoProvider?.delegate = self
    }    
}

extension PhotoViewerInteractorImpl: PhotoViewerInteractor {
    func startSearchingPhotos(with phrase: String) {
        metaPhotoProvider?.startSearchingPhotos(with: phrase)
    }
    
    func clearSearch() {
        metaPhotoProvider?.clearSearch()
        photoProvider?.clearPhotos()
        delegate?.dataChanged()
    }

    func itemsCount() -> Int {
        return metaPhotoProvider?.itemsCount() ?? 0
    }
    
    func item(for index: Int) -> (title: String?, image: UIImage?) {
        guard let model = metaPhotoProvider?.item(for: index) else {
            return (nil, nil)
        }
        
        return (model.title, photoProvider?.photo(for: model.id))
    }
}

extension PhotoViewerInteractorImpl: MetaPhotoProviderDelegate {
    func dataLoaded(_ models: [RemotePhotoModel]) {
        delegate?.dataChanged()
        photoProvider?.downloadPhotos(for: models)
    }
    
    func errorOccured(_ error: Error) {
        delegate?.errorOccured(error)
    }
}

extension PhotoViewerInteractorImpl: PhotoProviderDelegate {
    func photoChanged(for id: String) {
        guard let indexOfModel = metaPhotoProvider?.indexOfModel(with: id) else { return }
        delegate?.photoDownloaded(for: indexOfModel)
    }
}
