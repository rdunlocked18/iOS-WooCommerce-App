import UIKit
import SDWebImage
import FeedKit

class SocialCell: UICollectionViewCell {
    
    public static let identifier = "SocialCell"
        
    @IBOutlet fileprivate weak var containerView: UIView!
    
    //Views: Main content
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var captionView: UITextView!
    
    //Constraint: Height of image
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    //Views: Action buttons
    @IBOutlet weak var actionButtonContainer: UIView!
    @IBOutlet weak var actionImageCarrousel: UIImageView!
    @IBOutlet weak var actionImagePlay: UIImageView!
    
    //Constraints: Used to manage padding when there is no text/image
    @IBOutlet var captionTopSpacing: NSLayoutConstraint!
    @IBOutlet var captionBottomSpacing: NSLayoutConstraint!
    
    //Constraints: Used for imageView width computation
    @IBOutlet weak var imageRightPadding: NSLayoutConstraint!
    @IBOutlet weak var containerLeftPadding: NSLayoutConstraint!
    @IBOutlet weak var containerRightPadding: NSLayoutConstraint!
    @IBOutlet weak var imageLeftPadding: NSLayoutConstraint!
    
    //Views: Actions
    @IBOutlet weak var actionOneImage: UIImageView!
    @IBOutlet weak var actionOneText: UILabel!
    @IBOutlet weak var actionTwoImage: UIImageView!
    @IBOutlet weak var actionTwoText: UILabel!
    @IBOutlet weak var actionShareImage: UIImageView!
    
    public var sizeWithWidth: CGFloat?
    public var navigationController: UINavigationController?
    
    //Item attributes
    private var aspectRatio: Float?
    private var itemUrl: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        
        actionButtonContainer.layer.cornerRadius = 25
        actionButtonContainer.layer.masksToBounds = true
        
        userImageView.layer.cornerRadius = 22
        userImageView.layer.masksToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(shareTapped(tapGestureRecognizer:)))
        actionShareImage.isUserInteractionEnabled = true
        actionShareImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    public func updateLayout(){
        if (aspectRatio == -1) {
            imageHeight.constant = 0
        } else if let aspectRatio = aspectRatio {
            
            let width = sizeWithWidth! - imageLeftPadding.constant - imageRightPadding.constant - containerLeftPadding.constant - containerRightPadding.constant
            imageHeight.constant = width / CGFloat(aspectRatio)
        }
    }
    
    public func configureActionButtons(forKind: SocialItem.ItemKind){
        if (forKind == SocialItem.ItemKind.facebook || forKind == SocialItem.ItemKind.instagram) {
            actionOneImage.image = UIImage(named: "heart")
            actionTwoImage.image = UIImage(named: "comments")
        } else if (forKind == SocialItem.ItemKind.pinterest) {
            actionOneImage.image = UIImage(named: "pin")
            actionTwoImage.image = UIImage(named: "comments")
        } else if (forKind == SocialItem.ItemKind.twitter) {
            actionOneImage.image = UIImage(named: "heart")
            actionTwoImage.image = UIImage(named: "retweet")
        }
    }
    
    public func configureContentMode(forKind: SocialItem.ItemKind){
        if (forKind == SocialItem.ItemKind.instagram){
            imageView.contentMode = .scaleAspectFill
        } else {
            imageView.contentMode = .scaleAspectFit
        }
    }
    
    var item: SocialItem? {
        didSet {
            if let item = item {
                
                if item.imageUrls?.count ?? 0 > 0, let image = item.imageUrls?[0] {
                    imageView.isHidden = false
                    imageView.sd_setImage(with: URL(string: image))
                    
                    aspectRatio = item.imageAspect ?? 1.0
                    captionBottomSpacing.isActive = item.text != nil
                    updateLayout()
                } else {
                    imageView.isHidden = true
                    captionBottomSpacing.isActive = false
                    aspectRatio = -1.0
                    updateLayout()
                }
                
                if let caption = item.text {
                    captionView.text = String(htmlEncodedString: caption)
                    captionTopSpacing.isActive = true
                } else {
                    captionView.text = ""
                    captionTopSpacing.isActive = false
                }
                
                if item.videoUrl != nil {
                    actionButtonContainer.isHidden = false
                    actionImagePlay.isHidden = false
                    actionImageCarrousel.isHidden = true
                } else if (item.imageUrls?.count ?? 0 > 1) {
                    actionButtonContainer.isHidden = false
                    actionImagePlay.isHidden = true
                    actionImageCarrousel.isHidden = false
                } else {
                    actionButtonContainer.isHidden = true
                    actionImagePlay.isHidden = true
                    actionImageCarrousel.isHidden = true
                }
                
                if let url = item.url {
                    itemUrl = url
                } 
                
                configureActionButtons(forKind: item.itemKind!)
                configureContentMode(forKind: item.itemKind!)
                
                dateLabel.text = item.date
                userLabel.text = item.authorName
                
                userImageView.sd_setImage(with: URL(string: item.authorImageUrl!))
                
                actionOneText.text = item.counterOneCount!.roundedWithAbbreviations
                actionTwoText.text = item.counterTwoCount!.roundedWithAbbreviations
            }
        }
    }
    
    //TODO implement
    @objc func openTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let url = itemUrl {
            AppDelegate.openUrl(url: url, withNavigationController: navigationController!)
        }
    }
    
    @objc func shareTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let url = itemUrl {
            let objectsToShare = [url]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            if let wPPC = activityVC.popoverPresentationController {
                let tappedImage = tapGestureRecognizer.view as! UIImageView
                wPPC.sourceView = tappedImage
                wPPC.sourceRect = tappedImage.bounds
            }
            
            navigationController!.present(activityVC, animated: true, completion: nil)
        }
    }
    
}


extension Int {
    var roundedWithAbbreviations: String {
        let number = Double(self)
        let thousand = number / 1000
        let million = number / 1000000
        if million >= 1.0 {
            return "\(round(million*10)/10)M"
        }
        else if thousand >= 1.0 {
            return "\(round(thousand*10)/10)K"
        }
        else {
            return "\(Int(number))"
        }
    }
}
