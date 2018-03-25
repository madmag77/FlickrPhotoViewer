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
    func dataLoaded()
}

protocol PhotoViewerInteractor {
    func clearSearch()
    func startSearchingPhotos(with phrase: String)
    func updatePaging(with index: Int, outOf count: Int, searchString: String)
}

class PhotoViewerInteractorImpl {
    weak var delegate: PhotoViewerInteractorDelegate?
    weak var dataStore: PhotoViewerDataStoreWriter?
    private var photoSearchService: PhotoSearchService?
    private var pagingHandler: FlickrPaging?
    private var photoCache: PhotoCacheWriter?
    private var photoDownloadService: PhotoDownloadService?
    
    init(photoSearchService: PhotoSearchService?,
         photoDownloadService: PhotoDownloadService?,
         pagingHandler: FlickrPaging?,
         photoCache: PhotoCacheWriter?) {
        self.photoSearchService = photoSearchService
        self.photoSearchService?.delegate = self
        self.pagingHandler = pagingHandler
        self.photoDownloadService = photoDownloadService
        self.photoDownloadService?.delegate = self
        self.photoCache = photoCache
    }
    
    private func searchPhotos(with phrase: String, page: Int) {        
        photoSearchService?.searchPhotos(with: phrase, page: page)
    }
}

extension PhotoViewerInteractorImpl: PhotoViewerInteractor {
    func clearSearch() {
        dataStore?.clearAll()
        photoCache?.clearCache()
        pagingHandler?.clearPaging()
        delegate?.dataLoaded()
    }

    func startSearchingPhotos(with phrase: String) {
        searchPhotos(with: phrase, page: 1)
    }
    
    func updatePaging(with index: Int, outOf count: Int, searchString: String) {
        if let page = self.pagingHandler?.pageToFetchIfAny(showing: index, outOf: count) {
            searchPhotos(with: searchString, page: page)
        }
    }
}

extension PhotoViewerInteractorImpl: PhotoSearchServiceDelegate {
    func photosFound(_ photoModels: [RemotePhotoModel]) {
        dataStore?.addModels(photoModels)
        delegate?.dataLoaded()
        photoDownloadService?.downloadPhotos(for: photoModels)
    }
    
    func errorOccured(_ error: Error) {
        delegate?.errorOccured(error)
    }
}

extension PhotoViewerInteractorImpl: PhotoDownloadServiceDelegate {
    func justDownloadedImage(_ image: UIImage, for id: String) {
        photoCache?.setPhoto(image, for: id)
    }
}
