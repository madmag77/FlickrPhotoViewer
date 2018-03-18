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
    var downloadServiceMock: PhotoDownloadServiceMock?
    var delegateMock: DataStoreDelegateMock?
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
        downloadServiceMock = PhotoDownloadServiceMock()
        dataStore = PhotoViewerDataStore(photoDownloadService: downloadServiceMock,
                                         photosPerPage: testPhotosPerPage)
        
        dataStore?.delegate = delegateMock
    }
    
    override func tearDown() {
        dataStore = nil
        delegateMock = nil
        downloadServiceMock = nil
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
    
    func testPagingCallFetching() {
        // Given
        let models = testModels
        
        // When
        dataStore?.addModels(models)
        let _ = dataStore?.item(for: 0)
        
        // Then (too early for paging)
        XCTAssertNil(delegateMock?.requestPageCalledWithNum)
        
         // When
        let _  = dataStore?.item(for: models.count - 1)

        // Then (request next page - 2)
        wait(for: [(delegateMock?.expectationPage2)!], timeout: 1.0)
        
        // When
        dataStore?.addModels(models)
        let _  = dataStore?.item(for: models.count * 2 - testPhotosPerPage / 2)

        // Then (request next page - 3)
        wait(for: [(delegateMock?.expectationPage3)!], timeout: 1.0)
    }
    
    func testPagingResetAfterClear() {
        // Given
        let models = testModels
        
        // When
        dataStore?.addModels(models)
        let _ = dataStore?.item(for: 0)
        
        // Then
        XCTAssertNil(delegateMock?.requestPageCalledWithNum)
        
        // When
        let _  = dataStore?.item(for: models.count - 1)
        
        // Then (request next page - 2)
        wait(for: [(delegateMock?.expectationPage2)!], timeout: 1.0)

        // When
        dataStore?.clearAll()
        dataStore?.addModels(models)
        let _ = dataStore?.item(for: models.count - 1)
        
        // Then (again request next page - 3)
        wait(for: [(delegateMock?.expectationPage2)!], timeout: 1.0)
    }
    
    func testAskForDownloadingImage() {
        // Given
        let models = testModels
        
        // When
        dataStore?.addModels(models)
        let _ = dataStore?.item(for: 1)
        
        // Then
        XCTAssertEqual(downloadServiceMock?.getPhotoCalledWithModel?.id, models[1].id)
    }
    
    func testIfReturnRightImage() {
        // Given
        let models = testModels
        
        // When
        dataStore?.addModels(models)
        downloadServiceMock?.getPhotoImageToReturn = #imageLiteral(resourceName: "placeholder")
        let (_, image) = dataStore?.item(for: 1) ?? (nil, nil)
        
        // Then
        XCTAssertEqual(image, #imageLiteral(resourceName: "placeholder"))
    }
    
    func testIfCallDelegateAfterImageWasDownloaded() {
        // Given
        let models = testModels
        let indexToCallWith = 1
        
        // When
        dataStore?.addModels(models)
        dataStore?.justDownloadedImage(for: models[indexToCallWith].id)
        
        // Then
        XCTAssertEqual(delegateMock?.photoDownloadedCalledWithIndex, indexToCallWith)
    }
    
    func testIfNotCallDelegateAfterUnknownImageWasDownloaded() {
        // Given
        let models = testModels
        let strangeId = "STRANGE_ID"
        
        // When
        dataStore?.addModels(models)
        dataStore?.justDownloadedImage(for: strangeId)
        
        // Then
        XCTAssertNil(delegateMock?.photoDownloadedCalledWithIndex)
    }
    
    func testIfCallClearCacheWhenClearingSelfContent() {
        // Given
        let models = testModels
        
        // When
        dataStore?.addModels(models)
        dataStore?.clearAll()
        
        // Then
        XCTAssertTrue(downloadServiceMock?.clearCacheCalled ?? false)
    }
    
}

class PhotoDownloadServiceMock: PhotoDownloadService {
    var getPhotoCalledWithModel: RemotePhotoModel? = nil
    var clearCacheCalled: Bool = false
    var getPhotoImageToReturn: UIImage? = nil
    var delegate: PhotoDownloadServiceDelegate?
    
    func getPhoto(for model: RemotePhotoModel) -> UIImage? {
        getPhotoCalledWithModel = model
        return getPhotoImageToReturn
    }
    
    func clearCache() {
        clearCacheCalled = true
    }
}

class DataStoreDelegateMock: PhotoViewerDataStoreDelegate {
    let expectationPage2 = XCTestExpectation(description: "request page 2")
    let expectationPage3 = XCTestExpectation(description: "request page 3")
    var dataWasChangedCalled: Bool = false
    var requestPageCalledWithNum: Int? = nil
    var photoDownloadedCalledWithIndex: Int? = nil
    
    func dataWasChanged() {
        dataWasChangedCalled = true
    }
    
    func requestPage(with number: Int) {
        requestPageCalledWithNum = number
        if number == 2 {
            expectationPage2.fulfill()
        }
        
        if number == 3 {
            expectationPage3.fulfill()
        }
    }
    
    func photoDownloaded(for index: Int) {
        photoDownloadedCalledWithIndex = index
    }
    
    
}
