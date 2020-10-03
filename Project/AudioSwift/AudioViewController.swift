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
import MediaPlayer

final class AudioViewController: UICollectionViewController, UISearchBarDelegate{
    
    var params: NSArray!
    var isWordpress: Bool = false
    var estimateWidth = 300.0
    var cellMarginSize = 1
    var perPage = 50;

    let postType = PostCellCompact.identifier

    var sizingHelper = SizingHelper.init()
    
    var page = 0
    var canLoadMore = true
    var query: String?
    
    var refresher: UIRefreshControl?
        
    var items = [SoundCloudSong]()
    
    var wordpressClient: WordpressSwift?
    
    var footerView: FooterView?
    var searchButton: UIBarButtonItem?
    var cancelButton: UIBarButtonItem?
    var playButton: UIBarButtonItem?
    var searchBar: UISearchBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation Drawer
        self.collectionView?.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        self.collectionView?.addGestureRecognizer((self.revealViewController()?.tapGestureRecognizer())!)
        
        wordpressClient = WordpressSwift.init()
        
        setupSearch()
        setupRefresh()
        loadProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (PlayerViewController.isPlaying() && playButton == nil){
            playButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.play, target: self, action: #selector(AudioViewController.pauseButtonTapped))
            if navigationItem.rightBarButtonItems != nil {
               navigationItem.rightBarButtonItems! += [playButton!]
            } else {
                navigationItem.rightBarButtonItems = [playButton!]
            }
            
        }
    }
    
    @objc func pauseButtonTapped(){
        performSegue(withIdentifier: "playAudio", sender: nil)
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
        performSegue(withIdentifier: "playAudio", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playAudio" {
            if let nextViewController = segue.destination as? PlayerViewController{
                if (self.collectionView?.indexPathsForSelectedItems?.count ?? 0 > 0) {
                    PlayerViewController.playArray = self.items
                    PlayerViewController.playIndex = self.collectionView?.indexPathsForSelectedItems?[0].row
                    nextViewController.indexChanged = true
                }
            }
        }
    }
    
    func setupSearch() {
        if (!isWordpress) { return }
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
        
        if indexPath.row == items.count - 1 && canLoadMore {
            loadProducts()
        }
        
        return cell

    }
    
    func configureCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        if var annotateCell = cell as? PostCell {
            annotateCell.audio = self.items[indexPath.item]
        }
    }

    func identifierForPath(indexPath: IndexPath) -> String {
        return (self.items[indexPath.item].artWorkURL == nil) ?
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
        
        self.page += 1
        
        if (isWordpress) {
            let requestParams = RequestParams.init()
            requestParams.page = self.page
            if ((query) != nil) {
                requestParams.searchQuery = query!
            }
            if (params.count > 1 && !(params[1] as! String).isEmpty){
                requestParams.category = params[1] as? String
            }
            
            wordpressClient?.get(blogURL: params![0] as! String, params: requestParams, forType: WPPost.self, completionHandler: { (success, posts) in
                if (!success) {
                    
                    if (self.items.count == 0) {
                        self.handleNoResults()
                    }
                }
                
                var needsCompletionLater = false;
                
                if let results = posts {

                    for result in results {
                        let post = result as! WPPost
                        if (!post.attachmentsIncomplete) {
                            var audioAtt: WPAttachment?
                            for att in post.attachments {
                                if ((att.mime?.contains("audio/"))!){
                                    audioAtt = att
                                    break
                                }
                            }
                            
                            if (audioAtt != nil){
                                self.items.append(self.parseSongFromPost(post: post, audioAtt: audioAtt))
                            }
                        } else {
                            needsCompletionLater = true;
                            
                            post.completedAction = { value in
                                var audioAtt: WPAttachment?
                                for att in post.attachments {
                                    if ((att.mime?.contains("audio/"))!){
                                        audioAtt = att
                                        break
                                    }
                                }
                                
                                if (audioAtt != nil){
                                    self.items.append(self.parseSongFromPost(post: post, audioAtt: audioAtt))
                                    
                                    self.collectionView?.reloadData()
                                    self.collectionView?.layoutIfNeeded()
                                }
                            }
                        }
                    }
                    
                    
                    if (!needsCompletionLater){
                        self.collectionView?.reloadData()
                    }
                    self.handleResults(cantLoadMore: results.count == 0)
                }
                
                return
            })
        } else {

            SoundCloudAPI.sharedInstance()!.soundCloudSongs(params![0] as? String, type: params![1] as? String, offset: (page - 1) * perPage, limit: perPage, completionHandler: { resultArray, error in
                
                if (resultArray == nil) {
                    self.handleNoResults()
                } else {
                    
                    if let resultArray = resultArray {
                        self.items += resultArray as! [SoundCloudSong]
                    }
                    
                    self.collectionView?.reloadData()
                    self.handleResults(cantLoadMore: (resultArray?.count ?? 0) < 1)
                   
                }
                
            })
        }
    }
    
    func parseSongFromPost(post: WPPost, audioAtt: WPAttachment?) -> SoundCloudSong {
        let song = SoundCloudSong.init()
        song.title = post.title!
        if let medium = post.thumbnail.url, medium.count > 0  {
            song.artWorkURL = medium
        }
        if let high = post.featured_media.url, high.count > 0  {
            song.artWorkURLHigh = high
        }
        song.userName = post.author.name!
        song.stream_url = (audioAtt?.url)!
        
        //This is only available for audio retrieved through the RestAPIProvider
        if (audioAtt?.audio_meta != nil && audioAtt?.audio_meta?.length != nil){
            song.duration = audioAtt!.audio_meta!.length
        }
        return song
    }
    
    func handleNoResults(){
        let alertController = UIAlertController.init(title: NSLocalizedString("error", comment: ""), message: AppDelegate.NO_CONNECTION_TEXT, preferredStyle: UIAlertController.Style.alert)
        
        let ok = UIAlertAction.init(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default, handler: nil)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
        
        self.footerView?.isHidden = true
    }
    
    func handleResults(cantLoadMore: Bool){
        if (cantLoadMore) {
            self.canLoadMore = false
            self.footerView?.isHidden = true
        }
        
        self.refresher?.endRefreshing()
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
        self.items.removeAll()
        page = 0
        canLoadMore = true
        footerView?.isHidden = false
    }
    
}

extension AudioViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return sizingHelper.getSize(indexPath: indexPath, identifier: identifierForPath(indexPath: indexPath), forWidth: self.calculateWith(), with: configureCell(cell:indexPath:))
    }
    
    public func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.collectionView!.frame.size.width / estimatedWidth))
        
        let width = (self.view.safeAreaLayoutGuide.layoutFrame.width - CGFloat(cellMarginSize * 2) * (cellCount - 1)) / cellCount
        
        return width
    }
}

