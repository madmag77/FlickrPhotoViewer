//
//  PhotoViewerView.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit

protocol PhotoViewerView: class {
    func updatePhotosView()
    func updatePhoto(with index: Int)
}

fileprivate struct CollectionViewUISetup {
    static let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    static let itemsPerRow: Int = 3
    static let heightToWidthProportion: CGFloat = 1.2
    
    static func cellSize(collectionViewWidth: CGFloat) -> CGSize {
        let widthPerItem = collectionViewWidth / CGFloat(itemsPerRow)
        
        return CGSize(width: widthPerItem, height: widthPerItem * heightToWidthProportion)
    }
    
}
class PhotoViewerViewController: UIViewController {
    
    var output: PhotoViewerPresenter?

    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    let reuseIdentifierForPhotoCell = "PhotoCell"
    
    override func viewDidLoad() {
        navigationItem.title = NSLocalizedString("PhotoView.Title", comment: "")
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search for kittens"
        self.navigationItem.searchController = search
        self.navigationItem.hidesSearchBarWhenScrolling = true
        self.navigationController?.navigationBar.prefersLargeTitles = true

        output?.viewDidLoad()
    }
}

extension PhotoViewerViewController: PhotoViewerView {
    func updatePhotosView() {
        photoCollectionView.reloadData()
    }
    
    func updatePhoto(with index: Int) {
        guard index < photoCollectionView.numberOfItems(inSection: 0) else { return }
        photoCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
}

extension PhotoViewerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.isActive else {
            return
        }
        
        output?.changeSearchString(to: searchController.searchBar.text ?? "")
    }
}

extension PhotoViewerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return output?.itemsCount() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierForPhotoCell,
                                                      for: indexPath)

        return cell
    }
 
}

extension PhotoViewerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoCellItem else { return }
        output?.configureItem(cell, with: indexPath)
    }

}

extension PhotoViewerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing = 0.0
        
        return CollectionViewUISetup.cellSize(collectionViewWidth: collectionView.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return CollectionViewUISetup.sectionInsets
    }
    
}
