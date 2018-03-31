//
//  MetaPhotoProvider.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 31/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit
/*
protocol PhotoProviderDelegate: class {
    func justDownloadedImage(_ image: UIImage, for id: String)
    func errorOccured(_ error: Error)
}

protocol PhotoProvider {
    weak var delegate: PhotoProviderDelegate? {get set}
    
    func downloadPhotos(for models: [RemotePhotoModel])
    func photo(for id: String) -> UIImage?
}

class PhotoProviderImpl : PhotoProvider {
    private var photoDownloadService: PhotoSearchService?
    private var pagingHandler: FlickrPaging?
    private var metaPhotoCache: MetaCache?
    private var searchString: String?
    weak var delegate: MetaPhotoProviderDelegate?
    
    private func requestMoreModelsIfNeeded(with index: Int, outOf count: Int) {
        guard let searchString = searchString, let page = self.pagingHandler?.pageToFetchIfAny(showing: index, outOf: count) else {
            return
        }
        
        searchPhotos(with: searchString, page: page)
    }

    private func searchPhotos(with phrase: String, page: Int) {
        photoSearchService?.searchPhotos(with: phrase, page: page)
    }
    
    private func clearAll() {
        searchString = nil
        metaPhotoCache?.clear()
        pagingHandler?.clearPaging()
    }
    
    init(photoSearchService: PhotoSearchService?,
         pagingHandler: FlickrPaging?,
         metaPhotoCache: MetaCache?) {
        self.photoSearchService = photoSearchService
        self.pagingHandler = pagingHandler
        self.metaPhotoCache = metaPhotoCache
        self.photoSearchService?.delegate = self
    }

    func itemsCount() -> Int {
        return metaPhotoCache?.itemsCount()() ?? 0
    }
    
    func item(for index: Int) -> RemotePhotoModel? {
        requestMoreModelsIfNeeded(with: index, outOf: itemsCount())
        
        return metaPhotoCache?.item(for: index)()
    }
    
    func startSearchingPhotos(with phrase: String) {
        clearAll()
        searchString = phrase
        searchPhotos(with: phrase, page: 1)
    }
    
    func clearSearch() {
        clearAll()
    }
    
    func indexOfModel(with id: String) -> Int? {
        return metaPhotoCache?.itemIndex(for: id)()
    }
}

extension MetaPhotoProviderImpl: PhotoSearchServiceDelegate {
    func photosFound(_ photoModels: [RemotePhotoModel]) {
        metaPhotoCache?.addModels(photoModels)
        delegate?.dataLoaded(photoModels)
    }
    
    func errorOccured(_ error: Error) {
        delegate?.errorOccured(error)
    }
}
*/
