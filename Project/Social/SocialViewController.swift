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
import CollieGallery
import AVKit

final class SocialViewController: HideableCollectionViewController {
    
    var params: NSArray!
    var provider: NSNumber! //TODO we can do something different with a enum now everything is swifty
    var estimateWidth = 300.0
    var cellMarginSize = 1

    var sizingHelper = SizingHelper.init()
    
    var page = 1
    var pageToken: String?
    var canLoadMore = true
    
    var refresher: UIRefreshControl?
        
    var items = [SocialItem]()
    
    var client: SocialClient?
    
    var footerView: FooterView?
    var categorySlider: PostCategorySlider?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation Drawer
        self.collectionView?.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        self.collectionView?.addGestureRecognizer((self.revealViewController()?.tapGestureRecognizer())!)
        
        //Message to catch users still using parameters for JSON API. Remove as app matures or when API is integrated.
        if ((params[0] as! String).range(of: "http") != nil && (params[0] as! String).range(of: "wp-json/wp/v2/") == nil){
            let alertController = UIAlertController.init(title: "Outdated API", message: "You have entered parameters pointing to your JSON API. This is most likely because you haven't updated your apps configuration yet. As of this version of Universal, the JSON API is no longer supported. Please migrate to another API, see your documentation for more information", preferredStyle: UIAlertController.Style.alert)
            
            let ok = UIAlertAction.init(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        setupRefresh()
        loadPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGridView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.sizingHelper.clearCache()
        //self.collectionViewLayout.invalidateLayout()
        self.collectionView?.reloadData()
        
        /*coordinator.animate(alongsideTransition: { (_) in
            //
        }, completion: nil)*/
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let videoUrl = self.items[indexPath.row].videoUrl {
            let videoURL = URL(string: videoUrl)
            let player = AVPlayer(url: videoURL!)
            let playervc = AVPlayerViewController()
            playervc.player = player
            self.present(playervc, animated: true) {
                playervc.player!.play()
            }
        } else if self.items[indexPath.row].imageUrls?.count ?? 0 > 0 {
            var pictures = [CollieGalleryPicture]()
            
            for imageUrl in self.items[indexPath.row].imageUrls! {
                let picture = CollieGalleryPicture(url: imageUrl)
                pictures.append(picture)
            }
            
            let gallery = CollieGallery(pictures: pictures)
            gallery.presentInViewController(self)
        }
    }
    
    func setupGridView() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        if #available(iOS 11.0, *) {
           flow.sectionInsetReference = .fromSafeArea
        }
        
        let nibSocial = UINib(nibName: SocialCell.identifier, bundle: nil)
        collectionView?.register(nibSocial, forCellWithReuseIdentifier: SocialCell.identifier)
        
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SocialCell.identifier, for: indexPath)
        configureCell(cell: cell, indexPath: indexPath)
        
        if indexPath.row == items.count - 1 && canLoadMore {
            loadPosts()
        }
        
        return cell
    }
    
    func configureCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        if let annotateCell = cell as? SocialCell {
            annotateCell.sizeWithWidth = calculateWidth()
            annotateCell.item = self.items[indexPath.item]
            annotateCell.navigationController = self.navigationController
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
        loadPosts()
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func loadPosts() {
        if (client == nil) {
            client = SocialClient.init()
        }
        
        let requestParams = SocialRequestParams.init()
        requestParams.page = self.page
        requestParams.nextPageToken = self.pageToken
        if (params.count > 1 && !(params[1] as! String).isEmpty){
            requestParams.category = params[1] as? String
        }
        
        var provider: SocialProvider?
        if (self.provider == 1) {
            provider = FacebookProvider.init()
        } else if (self.provider == 2){
            provider = InstagramProvider.init()
        } else if (self.provider == 3){
            provider = PinterestProvider.init()
        } else if (self.provider == 4){
            provider = TwitterProvider.init()
        }
        
        client?.get(identifier: params[0] as! String, params: requestParams, provider: provider!, completionHandler: { (success, posts, pageToken) in
            if (!success) {
                
                if (self.items.count == 0) {
                    let alertController = UIAlertController.init(title: NSLocalizedString("error", comment: ""), message: AppDelegate.NO_CONNECTION_TEXT, preferredStyle: UIAlertController.Style.alert)
                    
                    let ok = UIAlertAction.init(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default, handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                    
                    self.footerView?.isHidden = true
                }
            }
            
            if let results = posts {
                self.items += results
                
                var canLoadMore = true
                if (provider is FacebookProvider || provider is InstagramProvider || provider is PinterestProvider) && pageToken == nil {
                    canLoadMore = false
                } else if (results.count == 0) {
                    canLoadMore = false
                }
                if (!canLoadMore) {
                    self.canLoadMore = false
                    self.footerView?.isHidden = true
                }
                
                self.collectionView?.reloadData()
                self.refresher?.endRefreshing()
                
                self.page += 1
            }
            
            self.pageToken = pageToken
            
            return
        })
    }
    
    func reset(){
        items.removeAll()
        page = 1
        pageToken = nil
        canLoadMore = true
        footerView?.isHidden = false
    }
    
}

extension SocialViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizingHelper.getSize(indexPath: indexPath, identifier: SocialCell.identifier, forWidth: self.calculateWidth(), with: configureCell(cell:indexPath:))
    }
    
    public func calculateWidth() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.collectionView!.frame.size.width / estimatedWidth))
        
        let width = (self.view.safeAreaLayoutGuide.layoutFrame.width - CGFloat(cellMarginSize * 2) * (cellCount - 1)) / cellCount
        
        return width
    }
}

