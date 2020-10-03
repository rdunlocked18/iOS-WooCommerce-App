import UIKit
import SDWebImage
import Cosmos
import WebKit
import CollieGallery
import LPSnackbar

final class PostDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, WKNavigationDelegate {
    
    // MARK: Properties

    var post: WPPost!
    var params:  NSArray!
    
    var related = [WPPost]()
    
    @IBOutlet weak var contentWebView: WKWebView!
    @IBOutlet weak var contentWebViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var relatedLabel: UILabel!
    @IBOutlet weak var relatedCollection: UICollectionView!
    @IBOutlet weak var relatedCollectionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var nameLabel: UILabel!

    @IBOutlet private weak var subTitleLabel: UILabel!

    @IBOutlet private weak var imageView: ImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    @IBOutlet private weak var postActionButton: UIButton!
    @IBOutlet weak var postActionButtonImage: UIImageView!
    
    @IBAction func postActionButtonTapped(_ sender: Any) {
        initGallery()
    }

    @objc private func shareButtonTapped() {
        if let postUrl = post.link {
            let objectsToShare = [postUrl]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            if let wPPC = activityVC.popoverPresentationController {
                wPPC.barButtonItem = navigationItem.rightBarButtonItems![0]
            }
            
            self.present(activityVC, animated: true, completion: nil)
        }
    }

    // MARK: View Life Cycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nc = self.navigationController as! TabNavigationController
        nc.turnTransparency(on: false, animated: true)
    }
    
    func initWebView(withBody: String) {
        let path = Bundle.main.path(forResource: "style", ofType: "css")
        if let style = try? String(contentsOfFile: path!, encoding: String.Encoding.utf8){
        
            let htmlStyling = String(format: "<html>" +
                "<head>" +
                "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1, user-scalable=0\" />" +
                "<style type=\"text/css\">" +
                "%@" +
                "</style>" +
                "</head>" +
                "<body>" +
                "<p>%@</p>" +
                "</body></html>", style, withBody);
    
            contentWebView.loadHTMLString(htmlStyling, baseURL: nil)
            contentWebView.scrollView.isScrollEnabled = false
            contentWebView.navigationDelegate = self
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.contentWebView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                self.contentWebView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    self.contentWebViewHeight.constant = height as! CGFloat
                })
            }
            
        })
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        setupRelated()
        self.scrollView.delegate = self
        
        // Customize the navigation bar.
        if (hasHeaderImage()){
            let nc = self.navigationController as! TabNavigationController
            nc.turnTransparency(on: true, animated: true)
        }

        let shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action: #selector(PostDetailViewController.shareButtonTapped))
        var rightItems = [shareButton]
        if (self.params.count > 2) {
            let commentButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.reply, target: self, action: #selector(PostDetailViewController.showDisqusComments))
            rightItems += [commentButton]
        }
        navigationItem.rightBarButtonItems = rightItems

        nameLabel.text = String(htmlEncodedString: post.title!)
        
        //WebView
        initWebView(withBody: post.content!)
        
        subTitleLabel.text = String(format: NSLocalizedString("date_author", comment: ""), post.author.name!, post.date!)

        // Load the image from the network and give it the correct aspect ratio.
        if (hasHeaderImage()) {
            imageView.sd_imageTransition = SDWebImageTransition.fade;
            imageView.sd_setImage(with: URL(string: post.featured_media.url!), placeholderImage: UIImage(named: "default_placeholder"), options: [], completed: { (image, error, cache, url) in
                self.imageView.updateAspectRatio()
            })
        } else {
            imageView.isHidden = true
            postActionButton.isHidden = true
            postActionButtonImage.isHidden = true
        }

        // Decorate the button.
        if (!AppDelegate.WP_ATTACHMENTS_BUTTON){
            postActionButton.isHidden = true
            postActionButtonImage.isHidden = true
        }
        postActionButton.round()
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(PostDetailViewController.initGallery))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(singleTap)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (imageView.isHidden) {
            let nc = self.navigationController as? TabNavigationController
            imageViewHeight.constant = nc?.getGradientView().frame.size.height ?? 0 + 10
        }
    }
    
    func hasHeaderImage() -> Bool {
        return (post.featured_media.url?.isEmpty == false)
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
        loadRelatedposts()
    }
    
    func loadRelatedposts() {
        
        let client = WordpressSwift.init()
        let requestParams = RequestParams.init()
        requestParams.page = 1
        if (post.tags != nil && post.tags!.count > 0) {
            requestParams.tag = post.tags![0]
        } else if (post.categories != nil && post.categories!.count > 0) {
            requestParams.category = post.categories![0]
        } else {
            relatedCollection.isHidden = true
            relatedLabel.isHidden = true
            self.relatedCollectionHeight.constant = 0
            return
        }
        
        client.get(blogURL: self.params![0] as! String, params: requestParams, forType: WPPost.self, completionHandler: { (success, posts) in
            //Do not show if no success or if only 1 result (that will be the current post)
            if (!success || (posts?.count ?? 0) <= 1) {
                self.relatedCollection.isHidden = true
                self.relatedLabel.isHidden = true
                self.relatedCollectionHeight.constant = 0
                return
            }
            
            if var results = posts {
                results.removeAll(where: {($0 as! WPPost).id == self.post.id})
                self.related += results as! [WPPost]
                self.relatedCollection.reloadData()
            }
            
            return
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPost"{
            if let nextViewController = segue.destination as? PostDetailViewController{
                nextViewController.post = self.related[(self.relatedCollection?.indexPathsForSelectedItems![0].item)!]
                nextViewController.params = self.params
            }
        }
    }
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.related.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath)
        if let annotateCell = cell as? PostCellLarge {
            annotateCell.post = self.related[indexPath.item]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = self.relatedCollection.frame.size.height - 20
        let widthHeightRatio = PostCellLarge.widthHeightRatioRelated
        return CGSize(width: height / CGFloat(widthHeightRatio), height: height)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
       if navigationAction.navigationType == .linkActivated  {
        AppDelegate.openUrl(url: navigationAction.request.url?.absoluteString, withNavigationController: self.navigationController)
            decisionHandler(WKNavigationActionPolicy.cancel);
       } else {
            decisionHandler(WKNavigationActionPolicy.allow);
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == relatedCollection) { return }
        if (!hasHeaderImage()){ return }
        
        let nc = self.navigationController as? TabNavigationController
        let transparent = scrollView.contentOffset.y < self.imageView.frame.size.height - ((nc?.getGradientView().frame.size.height != nil) ? (nc?.getGradientView().frame.size.height)! : 0);
        nc?.turnTransparency(on: transparent, animated: true)
    }
    
    @objc func showDisqusComments() {
        
        let disqusParam = self.params![2] as! String
        let rawIdentifier = disqusParam.components(separatedBy: ";")[2]
        let identifier = rawIdentifier.replacingOccurrences(of: "%d", with: "\(post.id!)")
        let shortname = disqusParam.components(separatedBy: ";")[1]
        let baseUrl = disqusParam.components(separatedBy: ";")[0]
        let pageurl = self.post.link!
        
        let html = "<html><head><meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0\"></head><body><div id=\"disqus_thread\"></div><script>var disqus_config = function () {this.page.url = \"\(pageurl)\"; this.page.identifier = \"\(identifier)\"; }; (function() {   var d = document, s = d.createElement('script'); s.src = 'https://\(shortname).disqus.com/embed.js'; s.setAttribute('data-timestamp', +new Date()); (d.head || d.body).appendChild(s);  })(); </script> <noscript>Please enable JavaScript to view the <a href=\"https://disqus.com/?ref_noscript\" rel=\"nofollow\">comments powered by Disqus.</a></noscript></html>"
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebViewController") as? WebViewSwiftController
        vc?.htmlString = html
        vc?.params = [baseUrl]
        vc?.basicMode = true
        if let aVc = vc {
            navigationController?.pushViewController(aVc, animated: true)
        }
    }
    
    @objc func initGallery(){
        if (post.attachmentsIncomplete){
            LPSnackbar.showSnack(title: NSLocalizedString("attachments_loading", comment: ""))
            //Optionally, use key-value observer to notify when ready.
            return
        }
        
        var pictures = [CollieGalleryPicture]()
        
        for attachment in post.attachments {
            if (attachment.url == nil || !(attachment.url?.starts(with: "http"))! || !(attachment.mime?.contains("image"))!) { continue }
            let picture = CollieGalleryPicture(url: attachment.url!.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!)
            pictures.append(picture)
        }
        
        if (pictures.count > 0) {
            let gallery = CollieGallery(pictures: pictures)
            gallery.presentInViewController(self)
        } else {
            LPSnackbar.showSnack(title: NSLocalizedString("no_attachments", comment: ""))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
