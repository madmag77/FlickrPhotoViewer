//
//  PhotoViewerBuilder.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit

struct PhotoViewerBuilder {
    func buildDefaultModule() -> UIViewController {
        let storyboard = UIStoryboard.init(name: "Main",
                                           bundle: nil)
        
        let view = storyboard.instantiateViewController(withIdentifier: "PhotoViewerView") as! PhotoViewerView
        
        return view

    }
}
