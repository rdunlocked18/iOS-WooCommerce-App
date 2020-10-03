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

final class YoutubeSwiftViewController: HideableCollectionViewController, UISearchBarDelegate{
    
    var params: NSArray!
    var estimateWidth = 300.0
    var cellMarginSize = 1
    
    //options: PostCellImmersive.identifier, PostCellLarge.identifier, PostCellCompact.identifier
    let postType = PostCellImmersive.identifier
    
    var sizingHelper = SizingHelper.init()
    
    var nextPageToken: String?
    var canLoadMore = true
    var query: String?
    
    var refresher: UIRefreshControl?
    
    var items = [Video]()
    
    var footerView: FooterView?
    var categorySlider: PostCategorySlider?
    var searchButton: UIBarButtonItem?
    var cancelButton: UIBarButtonItem?
    var searchBar: UISearchBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation Drawer
        self.collectionView?.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        self.collectionView?.addGestureRecognizer((self.revealViewController()?.tapGestureRecognizer())!)
        
        setupSearch()
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
        performSegue(withIdentifier: "showVideo", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVideo" {
            if let nextViewController = segue.destination as? VideoDetailViewController{
                nextViewController.video = self.items[(self.collectionView?.indexPathsForSelectedItems![0].item)!]
                nextViewController.params = params
            }
        } 
    }
    
    func setupSearch() {
        if (params![1] as? String == "playlist") { return }
        
        searchButton = UIBarButtonItem.init(barButtonSystemItem:UIBarButtonItem.SystemItem.search, target: self, action: #selector(searchClicked))
        
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItems = [searchButton!]
        
        cancelButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(searchBarCancelButtonClicked))
        
        searchBar = UISearchBar.init()
        self.searchBar?.searchBarStyle = UISearchBar.Style.default
        self.searchBar?.placeholder = NSLocalizedString("search", comment: "")
        self.searchBar?.delegate = self
    }
    
    func setupGridView() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        if #available(iOS 11.0, *) {
            flow.sectionInsetReference = .fromSafeArea
        }
        
        let nibCompact = UINib(nibName: PostCellCompact.identifier, bundle: nil)
        collectionView?.register(nibCompact, forCellWithReuseIdentifier: PostCellCompact.identifier)
        
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
        
        if indexPath.row == items.count - 1 && canLoadMore {
            loadProducts()
        }
        
        return cell
        
    }
    
    func configureCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        if var annotateCell = cell as? PostCell {
            annotateCell.video = self.items[indexPath.item]
        }
    }
    
    func identifierForPath(indexPath: IndexPath) -> String {
        if (indexPath.item == 0){
            return PostCellImmersive.identifier
        }
        
        return self.postType
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
        
        var parameter: String?
        var type: YoutubeClient.RequestType?
        if (query != nil) {
            parameter = params![0] as? String
            type = .query
        } else if (params![1] as! String == "playlist") {
            parameter =  params![0] as? String
            type = .playlist
        } else if (params![1] as! String  == "channel") {
            parameter =  params![0] as? String
            type = .channel
        } else if (params![1] as! String  == "live") {
            parameter =  params![0] as? String
            type = .live
        }
        
        YoutubeClient.getResults(parameter: parameter!, type: type!, search: query, pageToken: nextPageToken) { (success, nextPageToken, results) in
            if (!success) {
                if (self.items.count == 0) {
                    let alertController = UIAlertController.init(title: NSLocalizedString("error", comment: ""), message: AppDelegate.NO_CONNECTION_TEXT, preferredStyle: UIAlertController.Style.alert)
                    
                    let ok = UIAlertAction.init(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default, handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                    
                    self.footerView?.isHidden = true
                }
            } else {
                self.nextPageToken = nextPageToken
                self.items += results
           
                if (nextPageToken == nil) {
                    self.canLoadMore = false
                    self.footerView?.isHidden = true
                }
                
                self.collectionView?.reloadData()
                self.refresher?.endRefreshing()
                
            }
        }
    }
    
    @objc func searchClicked() {
        //[self setPullToRefreshEnabled:false];
        searchBar?.resignFirstResponder()
        searchButton?.isEnabled = false
        searchButton?.tintColor = UIColor.clear
        
        self.navigationItem.rightBarButtonItems = [cancelButton!]
        cancelButton?.tintColor = nil
        
        self.navigationItem.titleView = searchBar
        searchBar?.alpha = 0.0
        UIView.animate(withDuration: 0.2) {
            self.searchBar?.alpha = 1.0
        }
        searchBar?.becomeFirstResponder()
    }
    
    @objc func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //[self setPullToRefreshEnabled:true];
        
        UIView.animate(withDuration: 0.2, animations: {
            self.searchBar?.alpha = 0.0
            self.cancelButton?.tintColor = UIColor.clear
        }, completion:{ _ in
            self.navigationItem.titleView = nil
            self.navigationItem.rightBarButtonItems = [self.searchButton!]
            UIView.animate(withDuration: 0.2, animations: {
                self.searchButton?.isEnabled = true
                self.searchButton?.tintColor = nil
            })
        })
        
        //Reset
        reset()
        
        query = nil
        loadProducts()
        self.collectionView?.reloadData()
    }
    
    @objc func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        reset()
        
        query = searchBar.text
        loadProducts()
        self.collectionView?.reloadData()
    }
    
    func reset(){
        items.removeAll()
        nextPageToken = nil
        canLoadMore = true
        footerView?.isHidden = false
    }
    
}

extension YoutubeSwiftViewController: UICollectionViewDelegateFlowLayout {
    
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
                return CGSize(width: width, height: width * (9/16))
            }
            
            let width = self.calculateWith()
            return CGSize(width: width, height: width * 9/16)
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

