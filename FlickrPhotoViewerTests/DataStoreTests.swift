//
//  FlickrPhotoViewerTests.swift
//  FlickrPhotoViewerTests
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import XCTest
@testable import FlickrPhotoViewer

class DataStoreTests: XCTestCase {
    
    var dataStore: PhotoViewerDataStore?
    var delegateMock: DataStoreDelegateMock?
    var photoCacheMock: PhotoCacheReaderMock?
    
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
        delegateMock = DataStoreDelegateMock()
        photoCacheMock = PhotoCacheReaderMock()
        dataStore = PhotoViewerDataStore(photoCache: photoCacheMock)
        
        dataStore?.delegate = delegateMock
    }
    
    override func tearDown() {
        dataStore = nil
        delegateMock = nil
        photoCacheMock = nil
        super.tearDown()
    }
    
    func testAfterAddingModelReturnRightCount() {
        // Given
        let models = testModels
        
        // Then
        XCTAssertEqual(dataStore?.itemsCount(), 0)
        
        // When
        dataStore?.addModels(models)
        
        // Then
        XCTAssertEqual(dataStore?.itemsCount(), 2)
        XCTAssertTrue(delegateMock?.dataWasChangedCalled ?? false)
    }
    
    func testAfterAddingTwoTimesModelReturnRightCount() {
        // Given
        let models = testModels
        
        // When
        dataStore?.addModels(models)
        dataStore?.addModels(models)

        // Then
        XCTAssertEqual(dataStore?.itemsCount(), 4)
    }

    func testAfterClearingReturnRightCount() {
        // Given
        let models = testModels
        dataStore?.addModels(models)
        
        // When
        dataStore?.clearAll()
        
        // Then
        XCTAssertEqual(dataStore?.itemsCount(), 0)
        XCTAssertTrue(delegateMock?.dataWasChangedCalled ?? false)
    }
    
    func testAfterAddingModelReturnRightModel() {
        // Given
        let models = testModels
        
        // When
        dataStore?.addModels(models)
        let item = dataStore?.item(for: 1)
        
        // Then
        XCTAssertEqual(item?.title, models[1].title)
        XCTAssertNil(item?.image)
    }
    
    func testReturnNilOnTooBigIndex() {
        // Given
        let models = testModels
        
        // When
        dataStore?.addModels(models)
        let item = dataStore?.item(for: 10)
        
        // Then
        XCTAssertNil(item?.title)
        XCTAssertNil(item?.image)
    }
}

class DataStoreDelegateMock: PhotoViewerDataStoreDelegate {
    var dataWasChangedCalled: Bool = false
    var photoDownloadedCalledWithIndex: Int? = nil
    
    func dataWasChanged() {
        dataWasChangedCalled = true
    }
    
    func photoDownloaded(for index: Int) {
        photoDownloadedCalledWithIndex = index
    }
}

class PhotoCacheReaderMock: PhotoCacheReader {
    var photoCalled: Bool = false

    var delegate: PhotoCacheNotificationsDelegate?
    
    func photo(for itemId: String) -> () -> UIImage? {
        photoCalled = true
        return { nil }
    }
}

