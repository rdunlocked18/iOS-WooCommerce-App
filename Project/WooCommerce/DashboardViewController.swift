//
//  DashboardViewController.swift
//  Universal
//
//  Created by suraj medar on 22/07/20.
//  Copyright © 2020 VRCODEHUB. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class DashboardHeader: UICollectionReusableView {
    @IBOutlet weak var imageView: UIImageView!
}

class DashboardCategoriesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var captionLabel: UILabel!
}

class DashboardProductCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var cartBtn: UIButton!
    @IBOutlet weak var detailsLbl: UILabel!
}

class DashboardViewController: UIViewController, UISearchBarDelegate, UIScrollViewDelegate {
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
    var index = 0
    var categories = [WooProductCategory]()
    var product: WooProduct!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var productCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bannerView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar(largeTitleColor: .white, backgoundColor: .red, tintColor: .white, title: "Your Gastro App", preferredLargeTitle: true)
        title = "Your Gastro App"
        
        
        let url = URL(string: AppDelegate.WOOCOMMERCE_HOST)
        let key = AppDelegate.WOOCOMMERCE_KEY
        let secret = AppDelegate.WOOCOMMERCE_SECRET
        WooOS.init(url: url!, key: key, secret: secret)
        initCartButton()
        setupSearch()
        setupRefresh()
        loadCategories()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for _ in categoryCollectionView.visibleCells {
            var visibleRect = CGRect()
            visibleRect.origin = categoryCollectionView.contentOffset
            visibleRect.size = categoryCollectionView.bounds.size
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            guard let indexPath = categoryCollectionView.indexPathForItem(at: visiblePoint) else { return }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dashoboardProductDetails" {
            if let nextViewController = segue.destination as? ProductDetailViewController {
                nextViewController.product = product
            }
        } else if segue.identifier == "showCategory" {
            if let nextViewController = segue.destination as? WooCommerceViewController{
                nextViewController.params = [String(describing: headerView!.selectedCategory().id!)]
                nextViewController.title = String(htmlEncodedString: headerView!.selectedCategory().name!);
            }
        }
    }
    
    @IBAction func sideMenuBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "sideDrawerViewSegue", sender: nil)
    }
    
    func initCartButton(){
        let button = UIButton()
        button.setImage(UIImage(named: "carrt"), for: .normal)
        button.addTarget(self, action: #selector(cartClicked), for: .touchUpInside)
        cartButton = UIBarButtonItem(customView: button)
        cartButton = UIBarButtonItem.init(image: UIImage(named: "carrt"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(cartClicked))
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
    
    func setupRefresh(){
        self.productCollectionView!.alwaysBounceVertical = true
        refresher = UIRefreshControl()
        refresher!.addTarget(self, action: #selector(refreshCalled), for: .valueChanged)
        productCollectionView!.refreshControl = refresher;
    }
    
    @objc func refreshCalled() {
        reset()
        self.productCollectionView?.reloadData()
        loadProducts()
    }
    
    @objc func cartClicked() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let cartController = storyBoard.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
        self.navigationController?.pushViewController(cartController, animated: true)
    }
    
    @objc func getAddToCart(_ sender : UIButton) {
        product = items[sender.tag]
        Cart.sharedInstance.addProduct(product: product, controller: self.navigationController!)
    }
    
    @objc func searchClicked() {
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
        self.productCollectionView?.reloadData()
    }
    
    @objc func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        reset()
        query = searchBar.text
        loadProducts()
        self.productCollectionView?.reloadData()
    }
    
    func reset(){
        items.removeAll()
        page = 1
        canLoadMore = true
        footerView?.isHidden = false
    }
    
    func setBannerImage(result : WooProductImage) {
        bannerView.sd_setImage(with: result.src)
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseIn, animations: {
            self.bannerView.layoutIfNeeded()
        })
    }
    
}

extension DashboardViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return categories.count
        } else {
            return items.count
        }
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DashboardCategoriesCollectionViewCell
            let data = categories[indexPath.row]
            cell.captionLabel.text = data.name
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DashboardProductCollectionViewCell
            if indexPath.row < items.count {
                product = items[indexPath.row]
                let data = items[indexPath.row]
                cell.captionLabel.text = data.name
                cell.detailsLbl.text = data.shortDescription?.htmlStripped
                cell.commentLabel.text = formatPrice(value: data.price!)
                cell.cartBtn.tag = indexPath.row
                cell.cartBtn.addTarget(self, action: #selector(getAddToCart), for: .touchUpInside)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        if collectionView == categoryCollectionView {
            return CGSize(width: 110, height: 50)
        } else {
            return CGSize(width: (productCollectionView.frame.width), height: 130)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.productCollectionViewHeight.constant = self.productCollectionView.contentSize.height
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            index = indexPath.row
            if self.categories[self.index].image != nil {
                self.setBannerImage(result: self.categories[self.index].image!)
            }
            self.params = [String(describing: self.categories[self.index].id!)]
            self.catId = String(describing: self.categories[self.index].id!)
            self.page = 1
            self.items.removeAll()
            self.loadProducts()
            
        } else {
            self.product = items[indexPath.row]
            performSegue(withIdentifier: "dashoboardProductDetails", sender: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
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
    
}

extension DashboardViewController {
    func loadCategories() {
        if (categories.count > 0) { return }
        //  Mark:- Width Setup
        WooProductCategory.getList(with: 100) { (success, results, error) in
            if let error = error {
                print("result: ", results ?? "");
                print("Error searching : \(error)")
                return
            }
            if let results = results {
                self.categories += results
                self.setBannerImage(result: self.categories[self.index].image!)
                self.catId = "\(String(describing: self.categories[self.index].id))"
                self.params = [String(describing: self.categories[self.index].id!)]
                self.loadProducts()
                self.categoryCollectionView.reloadData()
            }
        }
    }
    
    func loadProducts() {
        var requestParams: [WooProductRequestParameter] = [WooProductRequestParameter.page(self.page)]
        requestParams.append(WooProductRequestParameter.category(catId))
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
                    
                    self.productCollectionView?.isHidden = true
                }
                return
            }
            
            if let results = results {
                self.items += results
                if (results.count == 0) {
                    self.canLoadMore = false
                    self.productCollectionView?.isHidden = true
                } else {
                    self.productCollectionView?.isHidden = false
                }
                
                if self.items.count != 0 {
                    self.productCollectionView.reloadData()
                }
                self.refresher?.endRefreshing()
                
                self.page += 1
            }
        }
    }
}

extension DashboardViewController {
    func configureNavigationBar(largeTitleColor: UIColor, backgoundColor: UIColor, tintColor: UIColor, title: String, preferredLargeTitle: Bool) {
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: largeTitleColor]
            navBarAppearance.titleTextAttributes = [.foregroundColor: largeTitleColor]
            navBarAppearance.backgroundColor = backgoundColor
            
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.compactAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
            
            navigationController?.navigationBar.prefersLargeTitles = preferredLargeTitle
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.tintColor = tintColor
            navigationItem.title = "Your Gastro App"
            
        } else {
            // Fallback on earlier versions
            navigationController?.navigationBar.barTintColor = backgoundColor
            navigationController?.navigationBar.tintColor = tintColor
            navigationController?.navigationBar.isTranslucent = false
            navigationItem.title = "YourGastroApp"
        }
    }
}
