import UIKit
import SDWebImage
import Cosmos
import CollieGallery

final class ProductDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate  {
    
    // MARK: Properties
    
    var product: WooProduct!
    
    var related = [WooProduct]()
    
    let htmlStyle = "<style>body{font-family:\"HelveticaNeue-Light\", \"Helvetica Neue Light\", \"Helvetica Neue\", Helvetica, Arial, \"Lucida Grande\", sans-serif; font-size:16px;}</style>"
    
    @IBOutlet weak var relatedCollection: UICollectionView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var nameLabel: UILabel!
    
    @IBOutlet private weak var ratingView: CosmosView!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet private weak var priceLabel: UILabel!
    
    @IBOutlet private weak var retailPriceLabel: UILabel!
    
    @IBOutlet private weak var percentOffLabel: UILabel!
    
    @IBOutlet private weak var imageView: ImageView!
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var detailsLabel: UILabel!
    
    @IBOutlet private weak var addToCartButton: UIButton!
    
    @IBAction func addToCartButtonTapped(_ sender: Any) {
        Cart.sharedInstance.addProduct(product: product, controller: self.navigationController!)
    }
    
    @objc private func shareButtonTapped() {
        // Use the TwitterKit to create a Tweet composer.
        if let productUrl = product.permalink {
            let objectsToShare = [productUrl]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            if let wPPC = activityVC.popoverPresentationController {
                wPPC.barButtonItem = navigationItem.rightBarButtonItems![0]
            }
            
            //activityVC.popoverPresentationController?.sourceView = self
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    // MARK: View Life Cycle
    
    //    override func viewWillDisappear(_ animated: Bool) {
    //        super.viewWillDisappear(animated)
    //        let nc = self.navigationController as! TabNavigationController
    //        nc.turnTransparency(on: false, animated: true)
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        setupRelated()
        self.scrollView.delegate = self
        
        // Customize the navigation bar.
        //        let nc = self.navigationController as! TabNavigationController
        //        nc.turnTransparency(on: true, animated: true)
        //
        //        let shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action: #selector(ProductDetailViewController.shareButtonTapped))
        //        navigationItem.rightBarButtonItem = shareButton
        
        // Add product name and description labels.
        nameLabel.text = product.name
        
        let htmlDescription = htmlStyle + product.productDescription!
        let htmlDescriptionData = NSString(string: htmlDescription).data(using: String.Encoding.unicode.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        descriptionLabel.attributedText = try! NSAttributedString(data: htmlDescriptionData!, options: options, documentAttributes: nil)
        
        //Product properties
        setupDetails()
        
        //Rating
        ratingView.rating = Double(product.averageRating!)!
        ratingLabel.text = String(format: NSLocalizedString("rating_count", comment: ""), product.ratingCount!)
        
        // Add the current and retail prices with their currency.
        priceLabel.text = formatPrice(value: product.price!)
        retailPriceLabel.text = nil
        percentOffLabel.text = nil
        if product.price! < product.regularPrice! {
            let retailPriceString = formatPrice(value: product.regularPrice!)
            let attributedRetailPrice = NSMutableAttributedString(string: retailPriceString)
            attributedRetailPrice.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, retailPriceString.count))
            attributedRetailPrice.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.lightGray, range: NSMakeRange(0, retailPriceString.count))
            retailPriceLabel.attributedText = attributedRetailPrice
            
            let discount = (1 - (product.price! / product.regularPrice!)) * 100
            percentOffLabel.text = "-\(discount.twoDigits())%"
        }
        
        // Load the image from the network and give it the correct aspect ratio.
        if (product.images?.isEmpty == false) {
            imageView.sd_imageTransition = SDWebImageTransition.fade;
            imageView.sd_setImage(with: product.images?[0].src, placeholderImage: UIImage(named: "default_placeholder"), options: [], completed: { (image, error, cache, url) in
                self.imageView.updateAspectRatio()
            })
        }
        
        // Draw a border around the product image and put a white background.
        
        // Decorate the button.
        addToCartButton.round()
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(PostDetailViewController.initGallery))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(singleTap)
    }
    
    func setupDetails() {
        var valueSet = [String: String]()
        
        if (product.categories!.count > 0){
            var categories = [String]()
            for cat in product.categories! {
                categories.append(cat.name!)
            }
            valueSet.updateValue(categories.joined(separator: ", "), forKey: NSLocalizedString("category", comment: ""))
        }
        
        
        if (product.tags!.count > 0){
            var tags = [String]()
            for tag in product.tags! {
                tags.append(tag.name!)
            }
            valueSet.updateValue(tags.joined(separator: ", "), forKey: NSLocalizedString("tags", comment: ""))
        }
        
        if (product.attributes!.count > 0){
            for attribute in product.attributes! {
                valueSet.updateValue(attribute.options!.joined(separator: ", "), forKey: attribute.name!)
            }
        }
        
        if (!(product.weight!.isEmpty)){
            valueSet.updateValue(String(format: "%@ %@", product.weight!, weight_unit), forKey: NSLocalizedString("weight", comment: ""))
        }
        
        if (!product.dimensions!.height!.isEmpty){
            valueSet.updateValue(String(format: "%@ x %@ x %@ %@", product.dimensions!.height!, product.dimensions!.width!, product.dimensions!.length!, size_unit), forKey: NSLocalizedString("dimensions", comment: ""))
        }
        
        //SKU
        valueSet.updateValue(String(product.id!), forKey: NSLocalizedString("sku", comment: "")) 
        
        var htmlDetails = htmlStyle
        for (key,value) in valueSet {
            htmlDetails += String(format: "<strong>%@</strong> %@<br>", key, value)
        }
        let htmlDetailsData = NSString(string: htmlDetails).data(using: String.Encoding.unicode.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        detailsLabel.attributedText = try! NSAttributedString(data: htmlDetailsData!, options: options, documentAttributes: nil)
    }
    
    func setupRelated() {
        relatedCollection.delegate = self
        relatedCollection.dataSource = self
        let flow = relatedCollection.collectionViewLayout as! UICollectionViewFlowLayout
        flow.scrollDirection = UICollectionView.ScrollDirection.horizontal
        relatedCollection.collectionViewLayout = flow
        if #available(iOS 11.0, *) {
            flow.sectionInsetReference = .fromSafeArea
        }
        loadRelatedProducts()
    }
    
    func loadRelatedProducts() {
        if (product.relatedIds == nil) { return }
        
        let requestParams: [WooProductRequestParameter] = [WooProductRequestParameter.include(product.relatedIds!)]
        
        WooProduct.getList(with: requestParams) { (success, results, error) in
            if let error = error {
                print("result: ", results ?? "");
                print("Error searching : \(error)")
                return
            }
            
            if let results = results {
                self.related += results
                self.relatedCollection.reloadData()
            }
        }
    }
    
    @objc func initGallery(){
        var pictures = [CollieGalleryPicture]()
        
        for image in product!.images! {
            if (image.src == nil) { break }
            let picture = CollieGalleryPicture(url: (image.src?.absoluteString)!)
            pictures.append(picture)
        }
        
        if (pictures.count > 0) {
            let gallery = CollieGallery(pictures: pictures)
            gallery.presentInViewController(self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProduct"{
            if let nextViewController = segue.destination as? ProductDetailViewController{
                nextViewController.product = self.related[(self.relatedCollection?.indexPathsForSelectedItems![0].item)!]
            }
        }
    }
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.related.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath)
        if let annotateCell = cell as? ProductCell {
            annotateCell.product = self.related[indexPath.item]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = self.relatedCollection.frame.size.height - 20
        let widthHeightRatio = ProductCell.widthHeightRatio
        return CGSize(width: height / CGFloat(widthHeightRatio), height: height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let nc = self.navigationController as? TabNavigationController
        let transparent = scrollView.contentOffset.y < self.imageView.frame.size.height - ((nc?.getGradientView().frame.size.height != nil) ? (nc?.getGradientView().frame.size.height)! : 0);
        nc?.turnTransparency(on: transparent, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension Float {
    func twoDigits() -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
