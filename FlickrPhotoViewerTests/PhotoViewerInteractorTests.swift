//
//  PhotoViewerInteractorTests.swift
//  FlickrPhotoViewerTests
//
//  Created by Artem Goncharov on 18/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import Foundation
import XCTest
@testable import FlickrPhotoViewer

class PhotoViewerInteractorTests: XCTestCase {
    
    var dataStoreMock: DataStoreWriterMock?
    var photoSearchServiceMock: PhotoSearchServiceMock?
    var delegateMock: PhotoViewerInteractorDelegateMock?
    var cacheMock: PhotoCacheWriterMock?
    var downloadServiceMock: PhotoDownloadServiceMock?
    var pagingMock: PagingMock?
    var interactor: PhotoViewerInteractorImpl?
    
    let testModels = [
        RemotePhotoModel(id: "id1",
                         farm: 1,
                         server: "server1",
                         secret: "secret1",
                         title: "title1"),
        
        RemotePhotoModel(id: "id2",
                         farm: 2,
                         server: "server2",
                         secret: "secret2",
                         title: "title2"),
        ]
    
    let testPhotosPerPage = 2
    
    override func setUp() {
        super.setUp()
        dataStoreMock = DataStoreWriterMock()
        photoSearchServiceMock = PhotoSearchServiceMock()
        delegateMock = PhotoViewerInteractorDelegateMock()
        cacheMock = PhotoCacheWriterMock()
        pagingMock = PagingMock()
        downloadServiceMock = PhotoDownloadServiceMock()
        
        interactor = PhotoViewerInteractorImpl(photoSearchService: photoSearchServiceMock,
                                               photoDownloadService: downloadServiceMock,
                                               pagingHandler: pagingMock,
                                               photoCache: cacheMock)
        interactor?.delegate = delegateMock
        interactor?.dataStore = dataStoreMock
    }
    
    override func tearDown() {
        interactor = nil
        delegateMock = nil
        photoSearchServiceMock = nil
        dataStoreMock = nil
        pagingMock = nil
        cacheMock = nil
        downloadServiceMock = nil
        
        super.tearDown()
    }
    
    func testSendRequestForSearchStringAndClearDS() {
        // Given
        let searchString = "searchString"
        let page = 1
        
        // When
        interactor?.startSearchingPhotos(with: searchString)
        
        // Then
        XCTAssertEqual(photoSearchServiceMock?.searchPhotosCalledWithPhraseAndPage.0, searchString)
        XCTAssertEqual(photoSearchServiceMock?.searchPhotosCalledWithPhraseAndPage.1, page)
    }
    
    func testSendRequestForSearchStringAndNotClearDS() {
        // Given
        let searchString = "searchString"
        let page = 2
        
        // When
        pagingMock?.pageToFetchIfAnyReturnValue = page
        interactor?.updatePaging(with: 1, outOf: 1, searchString: searchString)
        
        // Then
        XCTAssertEqual(photoSearchServiceMock?.searchPhotosCalledWithPhraseAndPage.0, searchString)
        XCTAssertEqual(photoSearchServiceMock?.searchPhotosCalledWithPhraseAndPage.1, page)
        XCTAssertFalse(dataStoreMock?.clearAllCalled ?? false)
    }
    
    func testAddedNewModelsToDS() {
        // Given
        let models = testModels
        
        // When
        interactor?.photosFound(models)
        
        // Then
        XCTAssertNotNil(dataStoreMock?.addModelsCalledWithModels)
        XCTAssertTrue(delegateMock?.dataLoadedCalled ?? false)
    }
    
    func testPropagateErrorFromServiceToPresenter() {
        // Given
        let error = ServerError()
        
        // When
        interactor?.errorOccured(error)
        
        // TODO: compare to real error
        // Then
        XCTAssertNotNil(delegateMock?.errorOccuredCalledWithError)
    }
    
}

class DataStoreWriterMock: PhotoViewerDataStoreWriter {
    var clearAllCalled: Bool = false
    var addModelsCalledWithModels: [RemotePhotoModel]? = nil
    
    func clearAll() {
        clearAllCalled = true
    }
    
    func addModels(_ models: [RemotePhotoModel]) {
        addModelsCalledWithModels = models
    }
}

class PhotoSearchServiceMock: PhotoSearchService {
    var searchPhotosCalledWithPhraseAndPage: (String?, Int?) = (nil, nil)

    var delegate: PhotoSearchServiceDelegate?
    
    func searchPhotos(with phrase: String, page: Int) {
        searchPhotosCalledWithPhraseAndPage = (phrase, page)
    }
}

class PhotoViewerInteractorDelegateMock: PhotoViewerInteractorDelegate {
    var dataLoadedCalled: Bool = false
    var errorOccuredCalledWithError: Error? = nil
    
    func errorOccured(_ error: Error) {
        errorOccuredCalledWithError = error
    }
    
    func dataLoaded() {
        dataLoadedCalled = true
    }
}

class PhotoCacheWriterMock: PhotoCacheWriter {
    var setPhotoCalled: Bool = false
    var clearCacheCalled: Bool = false
    
    func setPhoto(_ image: UIImage, for itemId: String) {
        setPhotoCalled = true
    }
    
    func clearCache() {
        clearCacheCalled = true
    }
}

class PhotoDownloadServiceMock: PhotoDownloadService {
    
    var getPhotoCalledWithModel: [RemotePhotoModel]? = nil
    var clearCacheCalled: Bool = false
    var delegate: PhotoDownloadServiceDelegate?
    
    func downloadPhotos(for models: [RemotePhotoModel]) {
        getPhotoCalledWithModel = models
    }
    
    func clearCache() {
        clearCacheCalled = true
    }
}

class PagingMock: FlickrPaging {
    var pageToFetchIfAnyCalled: Bool = false
    var pageToFetchIfAnyReturnValue: Int? = nil
    var clearPagingCalled: Bool = false
    
    func pageToFetchIfAny(showing index: Int, outOf count: Int) -> Int? {
        pageToFetchIfAnyCalled = true
        return pageToFetchIfAnyReturnValue
    }
    
    func clearPaging() {
        clearPagingCalled = true
    }
}

