//
//  PhotoViewerView.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit

protocol PhotoViewerView: class {
    
}

class PhotoViewerViewController: UIViewController {
    var output: PhotoViewerPresenter?

    override func viewDidLoad() {
        navigationItem.title = NSLocalizedString("PhotoView.Title", comment: "")
    }
}

extension PhotoViewerViewController: PhotoViewerView {
    
}
