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
        interactor = PhotoViewerInteractorImpl(photoSearchService: photoSearchServiceMock)
        interactor?.delegate = delegateMock
        interactor?.dataStore = dataStoreMock
    }
    
    override func tearDown() {
        interactor = nil
        delegateMock = nil
        photoSearchServiceMock = nil
        dataStoreMock = nil
        super.tearDown()
    }
    
    func testSendRequestForSearchStringAndClearDS() {
        // Given
        let searchString = "searchString"
        let page = 1
        
        // When
        interactor?.searchPhotos(with: searchString, page: page)
        
        // Then
        XCTAssertEqual(photoSearchServiceMock?.searchPhotosCalledWithPhraseAndPage.0, searchString)
        XCTAssertEqual(photoSearchServiceMock?.searchPhotosCalledWithPhraseAndPage.1, page)
        XCTAssertTrue(dataStoreMock?.clearAllCalled ?? false)
    }
    
    func testSendRequestForSearchStringAndNotClearDS() {
        // Given
        let searchString = "searchString"
        let page = 2
        
        // When
        interactor?.searchPhotos(with: searchString, page: page)
        
        // Then
        XCTAssertEqual(photoSearchServiceMock?.searchPhotosCalledWithPhraseAndPage.0, searchString)
        XCTAssertEqual(photoSearchServiceMock?.searchPhotosCalledWithPhraseAndPage.1, page)
        XCTAssertFalse(dataStoreMock?.clearAllCalled ?? false)
    }
    
    func testDoesntSendRequestBecauseOfEmptyString() {
        // Given
        let searchString = ""
        let page = 1
        
        // When
        interactor?.searchPhotos(with: searchString, page: page)
        
        // Then
        XCTAssertNil(photoSearchServiceMock?.searchPhotosCalledWithPhraseAndPage.0)
        XCTAssertNil(photoSearchServiceMock?.searchPhotosCalledWithPhraseAndPage.1)
        XCTAssertTrue(dataStoreMock?.clearAllCalled ?? false)
        // Need to update view after clearing DS
        XCTAssertTrue(delegateMock?.dataLoadedCalled ?? false)
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
