//
//  PhotosViewController.swift
//  Universal
//
//  Created by Mark on 03/03/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import CollieGallery

final class PhotosViewController: HideableCollectionViewController{
    
    var params: NSArray!
    var isTumblr: Bool = false
    var estimateWidth = 125.0
    var cellMarginSize = 1
    
    var page = 1
    var canLoadMore = true
    var query: String?
    
    var refresher: UIRefreshControl?
        
    var items = [Photo]()
    
    var client: PhotosClient?
    
    var footerView: FooterView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation Drawer
        self.collectionView?.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        self.collectionView?.addGestureRecognizer((self.revealViewController()?.tapGestureRecognizer())!)
        
        client = PhotosClient.init()
        
        setupRefresh()
        loadProducts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGridView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.collectionViewLayout.invalidateLayout()
        
        //coordinator.animate(alongsideTransition: { (_) in
                // layout update
        //}, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {        
        var pictures = [CollieGalleryPicture]()
        
        for attachment in items {
            if (attachment.url_full == nil || !(attachment.url_full?.starts(with: "http"))!) { continue }
            let picture = CollieGalleryPicture(url: attachment.url_full!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            pictures.append(picture)
        }
        
        if (pictures.count > 0) {
            let gallery = CollieGallery(pictures: pictures)
            gallery.presentInViewController(self)
            gallery.scrollToIndex(self.collectionView?.indexPathsForSelectedItems?[0].row ?? 0)
        }
    }

    func setupGridView() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        if #available(iOS 11.0, *) {
           flow.sectionInsetReference = .fromSafeArea
        }
        
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    func setupRefresh(){
        self.collectionView!.alwaysBounceVertical = true
        refresher = UIRefreshControl()
        refresher!.addTarget(self, action: #selector(refreshCalled), for: .valueChanged)
        collectionView!.refreshControl = refresher;
    }
    
    // tell the collection view how many cells to make
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    // make a cell for each cell index path
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath)
        configureCell(cell: cell, indexPath: indexPath)
        
        if indexPath.row == items.count - 1 && canLoadMore {
            loadProducts()
        }
        
        return cell
    }
    
    func configureCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        if let annotateCell = cell as? PhotoCell {
            annotateCell.photo = self.items[indexPath.item]
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                       withReuseIdentifier: "Footer", for: indexPath) as? FooterView
            footerView?.activityIndicator.startAnimating()
            return footerView!
        default:
            assert(false, "Unexpected element kind")
        }
        
        //Satisfy damn constraints
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    @objc func refreshCalled() {
        reset()
        self.collectionView?.reloadData()
        loadProducts()
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func loadProducts() {
        let requestParams = RequestParams.init()
        requestParams.page = self.page
        if ((query) != nil) {
            requestParams.searchQuery = query!
        }
        if (params.count > 1 && !(params[1] as! String).isEmpty){
            requestParams.category = params[1] as? String
        }
        
        
        client?.get(provider: isTumblr ? TumblrProvider() : FlickrProvider(), params: params as! [String], forPage: self.page, completionHandler: { (success, photos) in
            if (!success) {
                
                if (self.items.count == 0) {
                    let alertController = UIAlertController.init(title: NSLocalizedString("error", comment: ""), message: AppDelegate.NO_CONNECTION_TEXT, preferredStyle: UIAlertController.Style.alert)
                    
                    let ok = UIAlertAction.init(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default, handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                    
                    self.footerView?.isHidden = true
                }
            }
            
            if let results = photos {
                self.items += results
                
                if (results.count == 0) {
                    self.canLoadMore = false
                    self.footerView?.isHidden = true
                }
                
                self.collectionView?.reloadData()
                self.refresher?.endRefreshing()
                
                self.page += 1
            }
            
            return
        })
    }
    
    func reset(){
        items.removeAll()
        page = 1
        canLoadMore = true
        footerView?.isHidden = false
    }
    
}

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //For header immersive items, we use full width
        let width = self.calculateWith()
        return CGSize(width: width, height: width * CGFloat(PhotoCell.widthHeightRatio))
    }
    
    public func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.collectionView!.frame.size.width / estimatedWidth))
        
        let width = (self.view.safeAreaLayoutGuide.layoutFrame.width - CGFloat(cellMarginSize * 2) * (cellCount - 1)) / cellCount
        
        return width
    }
}

