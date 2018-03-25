//
//  PhotoViewerView.swift
//  FlickrPhotoViewer
//
//  Created by Artem Goncharov on 17/03/2018.
//  Copyright © 2018 MadMag. All rights reserved.
//

import UIKit

protocol PhotoViewerView: class {
    var configureCellItem: ((_ item: PhotoCellItem, _ title: String?, _ image: UIImage?) -> ())? {get set}
    func updatePhotosView()
    func updatePhoto(with index: Int)
    func showLoadingState()
    func showLoadedState()
    func showError(with string: String)
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
    var dataStore: PhotoViewerDataStoreReader?
    var configureCellItem: ((_ item: PhotoCellItem, _ title: String?, _ image: UIImage?) -> ())?

    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var heightOfLabel: NSLayoutConstraint!
    private let loadingLabelHeight: CGFloat = 21
    
    private let reuseIdentifierForPhotoCell = "PhotoCell"
    private let messagesAnimationDelay = 0.3
    private let errorMessageOnScreenDelay = 5.0

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
        self.heightOfLabel.constant = 0
        
        output?.viewDidLoad()
    }
}

extension PhotoViewerViewController: PhotoViewerView {
    func updatePhotosView() {
        photoCollectionView.reloadData()
    }
    
    func updatePhoto(with index: Int) {
        guard index < photoCollectionView.numberOfItems(inSection: 0) else { return }
        
        // This tricky construction is made in order to optimise collectionView updates
        // if number of visible items is not big - this code should work fast
        let visiblePaths = photoCollectionView.indexPathsForVisibleItems
        for path in visiblePaths {
            if path.row == index {
                photoCollectionView.reloadItems(at: [path])
            }
        }
    }
    
    func showLoadingState() {
        loadingLabel.text = NSLocalizedString("PhotoView.Loading", comment: "")
        self.heightOfLabel.constant = loadingLabelHeight

        UIView.animate(withDuration: messagesAnimationDelay) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showLoadedState() {
        self.heightOfLabel.constant = 0
        
        UIView.animate(withDuration: messagesAnimationDelay) {
            self.view.layoutIfNeeded()
        }

    }
    
    func showError(with string: String) {
        loadingLabel.text = NSLocalizedString("PhotoView.Error", comment: "") + " : " + string
        self.heightOfLabel.constant = loadingLabelHeight
        
        UIView.animate(withDuration: messagesAnimationDelay) {
            self.view.layoutIfNeeded()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + errorMessageOnScreenDelay) {
            self.showLoadedState()
        }
    }
}

extension PhotoViewerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.isActive else {
            return
        }
        
        output?.searchStringWasChanged(to: searchController.searchBar.text ?? "")
    }
}

extension PhotoViewerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataStore?.itemsCount() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierForPhotoCell,
                                                      for: indexPath)

        return cell
    }
 
}

extension PhotoViewerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let (title, image) = dataStore?.item(for: indexPath.row),
            let cell = cell as? PhotoCellItem else { return }
        
        configureCellItem?(cell, title, image)
        output?.willDisplayCell(with: indexPath.row, outOf: collectionView.numberOfItems(inSection: indexPath.section))
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
