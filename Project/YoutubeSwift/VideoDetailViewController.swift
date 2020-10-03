import UIKit
import SDWebImage
import Cosmos
import WebKit
import LPSnackbar
import XCDYouTubeKit
import AVKit
import AVFoundation
import KVOController

final class VideoDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, WKNavigationDelegate {
    
    // MARK: Properties
    
    static private let hideRelated = false

    var video: Video!
    var params:  NSArray!
    
    var related = [Video]()
    
    @IBOutlet weak var contentWebView: WKWebView!
    @IBOutlet weak var contentWebViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var relatedLabel: UILabel!
    @IBOutlet weak var relatedCollection: UICollectionView!
    @IBOutlet weak var relatedCollectionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var nameLabel: UILabel!

    @IBOutlet private weak var subTitleLabel: UILabel!

    @IBOutlet private weak var imageView: ImageView!
    
    @IBOutlet private weak var postActionButton: UIButton!

    struct YouTubeVideoQuality {
        static let hd720 = NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue)
        static let medium360 = NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue)
        static let small240 = NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue)
    }
    
    func playVideo(videoIdentifier: String?) {
        let playerViewController = AVPlayerViewController()
        self.present(playerViewController, animated: true, completion: nil)
        
        XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { [weak playerViewController] (video: XCDYouTubeVideo?, error: Error?) in
            if let streamURLs = video?.streamURLs, let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs[YouTubeVideoQuality.hd720] ?? streamURLs[YouTubeVideoQuality.medium360] ?? streamURLs[YouTubeVideoQuality.small240]) {
                playerViewController?.player = AVPlayer(url: streamURL)
                
                self.kvoController.observe(playerViewController?.player,
                                      keyPath: #keyPath(AVPlayer.currentItem.status),
                                      options: [.new, .initial]) { (viewController, player, change) in

                    let newStatus: AVPlayerItem.Status
                            if let newStatusAsNumber = change[NSKeyValueChangeKey.newKey.rawValue] as? NSNumber {
                        newStatus = AVPlayerItem.Status(rawValue: newStatusAsNumber.intValue)!
                    } else {
                        newStatus = .unknown
                    }
                    if newStatus == .failed {
                        NSLog("Error playing video")
                        self.dismiss(animated: true, completion: nil)
                        AppDelegate.openUrl(url: "https://www.youtube.com/watch?v=\(self.video.id!)", withNavigationController: self.navigationController)
                    }
                }
            
            } else {
                AppDelegate.openUrl(url: "https://www.youtube.com/watch?v=\(self.video.id!)", withNavigationController: self.navigationController)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func postActionButtonTapped(_ sender: Any) {
        playVideo(videoIdentifier: video.id!)
    }

    @objc private func shareButtonTapped() {
        let objectsToShare = ["https://www.youtube.com/watch?v=\(video.id!)"]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        if let wPPC = activityVC.popoverPresentationController {
            wPPC.barButtonItem = navigationItem.rightBarButtonItems![0]
        }
        
        self.present(activityVC, animated: true, completion: nil)
    }

    // MARK: View Life Cycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nc = self.navigationController as! TabNavigationController
        nc.getGradientView().turnTransparency(on: false, animated: true, tabController: self.navigationController)
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
        
        if (VideoDetailViewController.hideRelated){
            hideRelated()
        } else {
            setupRelated()
        }
        self.scrollView.delegate = self
        
        // Customize the navigation bar.
        if (hasHeaderImage()){
            let nc = self.navigationController as! TabNavigationController
            nc.getGradientView().turnTransparency(on: true, animated: true, tabController: self.navigationController)
        }

        let shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action: #selector(VideoDetailViewController.shareButtonTapped))
        let rightItems = [shareButton]
        navigationItem.rightBarButtonItems = rightItems

        nameLabel.text = String(htmlEncodedString: (video.snippet.title)!)
        
        //WebView
        initWebView(withBody: (video.snippet.description)!)
        
        subTitleLabel.text = String(format: NSLocalizedString("date_author", comment: ""), (video.snippet.channelTitle)!, (video.snippet.publishedAt)!)

        // Load the image from the network and give it the correct aspect ratio.
        if (hasHeaderImage()) {
            imageView.sd_imageTransition = SDWebImageTransition.fade;
            imageView.sd_setImage(with: URL(string: (video.snippet.thumbnails.high.url!)), placeholderImage: UIImage(named: "default_placeholder"), options: [], completed: { (image, error, cache, url) in
                //self.imageView.updateAspectRatio()
            })
        } else {
            imageView.isHidden = true
            postActionButton.isHidden = true
        }

        // Decorate the button.
        postActionButton.round()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func hasHeaderImage() -> Bool {
        return true
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
        
        //GET https://www.googleapis.com/youtube/v3/search?part=snippet&relatedToVideoId=5rOiW_xY-kc&type=video&key={YOUR_API_KEY}

        YoutubeClient.getResults(parameter: video.id!, type: YoutubeClient.RequestType.related, search: nil, pageToken: nil) { (success, nextPageToken, results) in
            if (!success) {
                self.hideRelated()
                return
            } else {
                self.related += results
                self.relatedCollection.reloadData()
                
            }
        }
    }
    
    func hideRelated(){
        self.relatedCollection.isHidden = true
        self.relatedLabel.isHidden = true
        self.relatedCollectionHeight.constant = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVideo"{
            if let nextViewController = segue.destination as? VideoDetailViewController{
                nextViewController.video = self.related[(self.relatedCollection?.indexPathsForSelectedItems![0].item)!]
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
            annotateCell.video = self.related[indexPath.item]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = self.relatedCollection.frame.size.height - 20
        let widthHeightRatio = PostCellLarge.widthHeightRatioRelatedVideo
        return CGSize(width: height / CGFloat(widthHeightRatio), height: height)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if ((navigationAction.request.url?.absoluteString.contains("http"))! && (navigationAction.targetFrame?.isMainFrame)!){
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
