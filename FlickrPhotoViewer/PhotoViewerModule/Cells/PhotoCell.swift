//
//  PhotoCell.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit

protocol PhotoCellItem {
    func setTitle(_ title: String)
    func setPhoto(_ image: UIImage)
}

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    override func prepareForReuse() {
        photo.image = #imageLiteral(resourceName: "placeholder")
        title.text = ""
    }
}

extension PhotoCell: PhotoCellItem {
    func setTitle(_ title: String) {
        self.title.text = title
    }
    
    func setPhoto(_ image: UIImage) {
        photo.image = image
    }
}
