//
//  WooCommerceViewController.swift
//  Universal
//
//  Created by Mark on 03/03/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

final class WooCommerceViewController: HideableCollectionViewController, UISearchBarDelegate {
    
    var params: NSArray!
    var estimateWidth = 300
    var cellMarginSize = 1.0
    
    var page = 1
    var canLoadMore = true
    var query: String?
    var category: String?
    
    var refresher: UIRefreshControl?
    
    var items = [WooProduct]()
    
    var footerView: FooterView?
    var headerView: CategorySlider?
    var searchButton: UIBarButtonItem?
    var cancelButton: UIBarButtonItem?
    var cartButton: UIBarButtonItem?
    var searchBar: UISearchBar?
    var catId : String = ""
    var type = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation Drawer
        self.collectionView?.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        self.collectionView?.addGestureRecognizer((self.revealViewController()?.tapGestureRecognizer())!)
        
        let url = URL(string: AppDelegate.WOOCOMMERCE_HOST)
        let key = AppDelegate.WOOCOMMERCE_KEY
        let secret = AppDelegate.WOOCOMMERCE_SECRET
        
        WooOS.init(url: url!, key: key, secret: secret)
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout // casting is required because UICollectionViewLayout doesn't offer header pin. Its feature of UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        initCartButton()
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
        coordinator.animate(alongsideTransition: { (_) in
            self.collectionViewLayout.invalidateLayout() // layout update
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProduct" {
            if let nextViewController = segue.destination as? ProductDetailViewController {
                nextViewController.product = self.items[(self.collectionView?.indexPathsForSelectedItems![0].item)!]
            }
        } else if segue.identifier == "showCategory" {
            if let nextViewController = segue.destination as? WooCommerceViewController{
                nextViewController.params = [String(describing: headerView!.selectedCategory().id!)]
                nextViewController.title = String(htmlEncodedString: headerView!.selectedCategory().name!);
            }
        }
    }
    
    func setupSearch() {
        searchButton = UIBarButtonItem.init(barButtonSystemItem:UIBarButtonItem.SystemItem.search, target: self, action: #selector(searchClicked))
        
        initCartButton()
        
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItems = [cartButton!, searchButton!]
        
        cancelButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(searchBarCancelButtonClicked))
        
        searchBar = UISearchBar.init()
        self.searchBar?.searchBarStyle = UISearchBar.Style.default
        self.searchBar?.placeholder = NSLocalizedString("search", comment: "")
        self.searchBar?.delegate = self
    }
    
    func initCartButton(){
        let button = UIButton()
        button.setImage(UIImage(named: "cart"), for: .normal)
        button.addTarget(self, action: #selector(cartClicked), for: .touchUpInside)
        cartButton = UIBarButtonItem(customView: button)
        cartButton = UIBarButtonItem.init(image: UIImage(named: "cart"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(cartClicked))
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
    
    @objc func refreshCalled() {
        reset()
        self.collectionView?.reloadData()
        loadProducts()
    }
    
    
    // MARK: - UICollectionViewDelegate protocol
    
    @objc func cartClicked() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let cartController = storyBoard.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
        self.navigationController?.pushViewController(cartController, animated: true)
    }
    
    @objc func searchClicked() {
        //[self setPullToRefreshEnabled:false];
        searchBar?.resignFirstResponder()
        searchButton?.isEnabled = false
        searchButton?.tintColor = UIColor.clear
        
        self.navigationItem.rightBarButtonItems = [cartButton!, cancelButton!]
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
            self.navigationItem.rightBarButtonItems = [self.cartButton!, self.searchButton!]
            UIView.animate(withDuration: 0.2, animations: {
                self.searchButton?.isEnabled = true
                self.searchButton?.tintColor = nil
            })
        })
        //Show footerView
        
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
        page = 1
        canLoadMore = true
        footerView?.isHidden = false
    }
    
}

extension WooCommerceViewController: UICollectionViewDelegateFlowLayout {
    
    // tell the collection view how many cells to make
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // make a cell for each cell index path
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath)
        
        if let annotateCell = cell as? ProductCell {
            annotateCell.product = self.items[indexPath.item]
        }
        
        if indexPath.item == items.count - 1 && canLoadMore {
            loadProducts()
        }
        
        return cell
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
        case UICollectionView.elementKindSectionHeader:
            headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "Header", for: indexPath) as? CategorySlider
            if (params.count == 0 || (params[0] as! String).isEmpty){
                headerView?.loadCategories()
                
//                self.params = [String(describing: self.headerView?.categories[indexPath.row].id!)]
//                self.catId = String(describing: self.headerView?.categories[indexPath.row].id!)
//                self.loadProducts()
                
            }
            return headerView!
        default:
            assert(false, "Unexpected element kind")
        }
        
        //Satisfy damn constraints
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if (params.count == 0 || (params[0] as! String).isEmpty) {
            return CGSize(width: 100, height: 50)
        } else {
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: 100)
    }
    
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize * 2) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}

extension WooCommerceViewController {
    func loadProducts() {
        var requestParams: [WooProductRequestParameter] = [WooProductRequestParameter.page(self.page)]
        if ((category) != nil) {
            requestParams.append(WooProductRequestParameter.category(catId))
        }
        
        if ((query) != nil) {
            requestParams.append(WooProductRequestParameter.search(query!))
        }
        
        if (params.count > 0 && !(params[0] as! String).isEmpty){
            requestParams.append(WooProductRequestParameter.category(params[0] as! String))
        }
        
        WooProduct.getList(with: requestParams) { (success, results, error) in
            if let error = error {
                print("result: ", results ?? "");
                print("Error searching : \(error)")
                if (self.items.count == 0) {
                    let alertController = UIAlertController.init(title: NSLocalizedString("error", comment: ""), message: AppDelegate.NO_CONNECTION_TEXT, preferredStyle: UIAlertController.Style.alert)
                    let ok = UIAlertAction.init(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default, handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                    
                    self.footerView?.isHidden = true
                }
                return
            }
            if let results = results {
                self.items += results
                if (results.count == 0) {
                    self.canLoadMore = false
                    self.footerView?.isHidden = true
                }
                self.refresher?.endRefreshing()
                self.page += 1
            }
        }
    }
}
