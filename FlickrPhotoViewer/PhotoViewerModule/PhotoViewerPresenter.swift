//
//  PhotoViewerPresenter.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import Foundation

protocol PhotoViewerPresenter {
    
}

class PhotoViewerPresenterImpl {
    var interactor: PhotoViewerInteractor?
    weak var view: PhotoViewerView?
    
    
}

extension PhotoViewerPresenterImpl: PhotoViewerPresenter {
    
}

extension PhotoViewerPresenterImpl: PhotoViewerInteractorDelegate {
    
}
