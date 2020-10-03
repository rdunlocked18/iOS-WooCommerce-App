import UIKit
import SDWebImage
import FeedKit

class PostCellCompact: UICollectionViewCell, PostCell {
    
    public static let identifier = "PostCellCompact"
        
    @IBOutlet fileprivate weak var containerView: UIView!
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var captionLabel: UILabel!
    @IBOutlet fileprivate weak var commentLabel: UILabel!
    @IBOutlet weak var aspectRatioConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
    }
    
    var post: WPPost? {
        didSet {
            if let post = post {
                if let image = post.featured_media.url {
                    imageView.sd_setImage(with: URL(string: image))
                } 
                captionLabel.text = String(htmlEncodedString: post.title!)
                commentLabel.text = post.date
            }
        }
    }
    
    var item: RSSFeedItem? {
        didSet {
            if let item = item {
                if let image = item.getImageUrl() {
                    imageView.sd_setImage(with: URL(string: image))
                }
                captionLabel.text = String(htmlEncodedString: item.title!)
                commentLabel.text = item.pubDate?.toString()
            }
        }
    }
    
    var video: Video? {
        didSet {
            if let item = video {
                imageView.sd_setImage(with: URL(string: (item.snippet.thumbnails.high.url)!))
                captionLabel.text = String(htmlEncodedString: (item.snippet.title)!)
                commentLabel.text = item.snippet.publishedAt
                aspectRatioConstraint.priority = UILayoutPriority(rawValue: 998)
            }
        }
    }
    
    var audio: SoundCloudSong? {
        didSet {
            if let item = audio {
                if let artWorkUrl = item.artWorkURL {
                    imageView.sd_setImage(with: URL(string: artWorkUrl))
                }
                captionLabel.text = String(htmlEncodedString: (item.title))
                
                commentLabel.text = (item.duration != nil) ? String(format: NSLocalizedString("audio_subtitle", comment: ""), item.userName, item.duration!.makeMilisecondsRedeable()) : item.userName
            }
        }
    }
    
    /**
     ----------------------------------------------------------------------------
     - If we want to use this type of calculations again (based on autolayout)  -
     ----------------------------------------------------------------------------
     
     requires: flow.estimatedItemSize = CGSize(width: self.calculateWith(), height: 88.0)
     
    lazy var width: NSLayoutConstraint = {
     let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
     width.isActive = true
     return width
     }()
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width 
        
        setNeedsLayout()
        layoutIfNeeded()
        
        var size = contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: UILayoutFittingCompressedSize.height));
        //var size = contentView..systemLayoutSizeFitting(size, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        
        //When error is fixed check whether this constraint is needed still?
        //let height = contentView.heightAnchor.constraint(equalToConstant: size.height)
        //height.isActive = true
                
        return size
    }**/

    
}
