//
//  WordpressSwiftViewController.swift
//  Universal
//
//  Created by Mark on 03/03/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import FeedKit

final class RssSwiftViewController: HideableCollectionViewController{
    
    var params: NSArray!
    var estimateWidth = 300.0
    var cellMarginSize = 1
    
    let postType = PostCellCompact.identifier //options: PostCellImmersive.identifier, PostCellLarge.identifier, PostCellCompact.identifier

    var sizingHelper = SizingHelper.init()
    
    var refresher: UIRefreshControl?
        
    var items = [RSSFeedItem]()
    var footerView: FooterView?
    
    var client: FeedParser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation Drawer
        self.collectionView?.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        self.collectionView?.addGestureRecognizer((self.revealViewController()?.tapGestureRecognizer())!)
        
        client = FeedParser(URL: URL(string: params![0] as! String)!)
        
        setupRefresh()
        loadProducts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGridView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        sizingHelper.clearCache()
        self.collectionViewLayout.invalidateLayout()
        
        //coordinator.animate(alongsideTransition: { (_) in
                // layout update
        //}, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {        
        performSegue(withIdentifier: "showItem", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItem" {
            if let nextViewController = segue.destination as? ItemDetailViewController{
                nextViewController.item = self.items[(self.collectionView?.indexPathsForSelectedItems![0].item)!]
            }
        }
    }
    
    func setupGridView() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        if #available(iOS 11.0, *) {
           flow.sectionInsetReference = .fromSafeArea
        }
        
        let nibCompact = UINib(nibName: PostCellCompact.identifier, bundle: nil)
        collectionView?.register(nibCompact, forCellWithReuseIdentifier: PostCellCompact.identifier)
        let nibText = UINib(nibName: PostCellText.identifier, bundle: nil)
        collectionView?.register(nibText, forCellWithReuseIdentifier: PostCellText.identifier)
        
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.identifierForPath(indexPath: indexPath), for: indexPath)
        configureCell(cell: cell, indexPath: indexPath)
        
        return cell

    }
    
    func configureCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        if var annotateCell = cell as? PostCell {
            annotateCell.item = self.items[indexPath.item]
        }
    }

    func identifierForPath(indexPath: IndexPath) -> String {

        if (indexPath.item == 0 && self.items[indexPath.item].getImageUrl() != nil){
            return PostCellImmersive.identifier
        }
        
        return (self.items[indexPath.item].getImageUrl() == nil) ?
            PostCellText.identifier : self.postType
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
        
        client!.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            
             DispatchQueue.main.async {
                
                self.footerView?.isHidden = true
                
                if (result.isFailure) {
                    let alertController = UIAlertController.init(title: NSLocalizedString("error", comment: ""), message: AppDelegate.NO_CONNECTION_TEXT, preferredStyle: UIAlertController.Style.alert)
                    
                    let ok = UIAlertAction.init(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default, handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                
                if let resultItems = result.rssFeed?.items {
                    self.items += resultItems
                    
                    self.collectionView?.reloadData()
                    self.refresher?.endRefreshing()
                }
            }
            
            return
        }
    }
    
    func reset(){
        items.removeAll()
    }
    
}

extension RssSwiftViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (identifierForPath(indexPath: indexPath) == PostCategorySlider.identifierX) {
            let width = CGFloat(self.collectionView!.frame.size.width)
            return CGSize(width: width, height: 45.0)
        } else if (identifierForPath(indexPath: indexPath) == PostCellLarge.identifier) {
            let width = self.calculateWith()
            return CGSize(width: width, height: width * CGFloat(PostCellLarge.widthHeightRatio))
        } else if (identifierForPath(indexPath: indexPath) == PostCellImmersive.identifier) {
            //For header immersive items, we use full width
            if (indexPath.item == 0) {
                let width = CGFloat(self.collectionView!.frame.size.width)
                return CGSize(width: width, height: 220.0)
            }
            
            let width = self.calculateWith()
            return CGSize(width: width, height: width * CGFloat(PostCellImmersive.widthHeightRatio))
        } else {
            return sizingHelper.getSize(indexPath: indexPath, identifier: identifierForPath(indexPath: indexPath), forWidth: self.calculateWith(), with: configureCell(cell:indexPath:))
        }
    }
    
    public func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.collectionView!.frame.size.width / estimatedWidth))
        
        let width = (self.view.safeAreaLayoutGuide.layoutFrame.width - CGFloat(cellMarginSize * 2) * (cellCount - 1)) / cellCount
        
        return width
    }
    
}

