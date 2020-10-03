import UIKit
import SDWebImage
import Cosmos
import WebKit
import CollieGallery
import LPSnackbar
import FeedKit

final class ItemDetailViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {
    
    // MARK: Properties

    var item: RSSFeedItem!
    
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

    @IBAction func postActionButtonTapped(_ sender: Any) {
        initGallery()
    }

    @objc private func shareButtonTapped() {
        if let postUrl = item.link {
            let objectsToShare = [postUrl]
            let webviewShare = ShareToWebView()
            webviewShare.navController = self.navigationController
            let applicationActivities = [webviewShare]

            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: applicationActivities)
            
            if let wPPC = activityVC.popoverPresentationController {
                wPPC.barButtonItem = navigationItem.rightBarButtonItems![0]
            }
            
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @objc private func playButtonTapped() {
        var mediaUrlDef: String?
        if let mediaUrl = self.item.media?.mediaContents?[0].attributes?.url {
            mediaUrlDef = mediaUrl
        } else if let mediaUrl = self.item.enclosure?.attributes?.url {
            mediaUrlDef = mediaUrl
        }
        AppDelegate.openUrl(url: mediaUrlDef, withNavigationController: self.navigationController)
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
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            AppDelegate.openUrl(url: navigationAction.request.url?.absoluteString, withNavigationController: self.navigationController)
            decisionHandler(WKNavigationActionPolicy.cancel);
        } else {
            decisionHandler(WKNavigationActionPolicy.allow);
        }
    }

    func removeFirstImageIfNeeded(html: String) -> String {
        var html = html
        if (true) {
            
            let regexStr = "<img ([^>]+)>"
            
            let regex = try? NSRegularExpression(pattern: regexStr, options: .caseInsensitive)
            let range = regex?.rangeOfFirstMatch(in: html, options: [], range: NSRange(location: 0, length: html.count))
            
            if Int(range?.location ?? 0) != NSNotFound {
                if let aRange = range {
                    html = regex!.stringByReplacingMatches(in: html, options: [], range: aRange, withTemplate: "$2")
                }
            }
            
            return html
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        self.scrollView.delegate = self
        
        // Customize the navigation bar.
        if (hasHeaderImage()){
            let nc = self.navigationController as! TabNavigationController
            nc.turnTransparency(on: true, animated: true)
        }

        
        let shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action: #selector(ItemDetailViewController.shareButtonTapped))
        var rightItems = [shareButton]
        if (self.item.media?.mediaContents?.count ?? 0 > 0 || self.item.enclosure?.attributes?.url?.count ?? 0 > 0 ) {
            let playButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.play, target: self, action: #selector(ItemDetailViewController.playButtonTapped))
            rightItems += [playButton]
        }
        navigationItem.rightBarButtonItems = rightItems
        
        nameLabel.text = String(htmlEncodedString: item.title!)
        
        //WebView
        if let description = item.content?.contentEncoded ?? item.description {
            initWebView(withBody: self.removeFirstImageIfNeeded(html: description))
        }
        
        subTitleLabel.text = item.pubDate?.toString()

        // Load the image from the network and give it the correct aspect ratio.
        if (hasHeaderImage()) {
            imageView.sd_imageTransition = SDWebImageTransition.fade;
            imageView.sd_setImage(with: URL(string: item.getImageUrl()!), placeholderImage: UIImage(named: "default_placeholder"), options: [], completed: { (image, error, cache, url) in
                self.imageView.updateAspectRatio()
            })
        } else {
            imageView.isHidden = true
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ItemDetailViewController.initGallery))
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
        return (item.getImageUrl() != nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == relatedCollection) { return }
        if (!hasHeaderImage()){ return }
        
        let nc = self.navigationController as? TabNavigationController
        let transparent = scrollView.contentOffset.y < self.imageView.frame.size.height - ((nc?.getGradientView().frame.size.height != nil) ? (nc?.getGradientView().frame.size.height)! : 0);
        nc?.turnTransparency(on: transparent, animated: true)
    }
    
    @objc func initGallery(){
        
        var pictures = [CollieGalleryPicture]()
        
        let picture = CollieGalleryPicture(url: self.item.getImageUrl()!)
        pictures.append(picture)
        
        let gallery = CollieGallery(pictures: pictures)
        gallery.presentInViewController(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
