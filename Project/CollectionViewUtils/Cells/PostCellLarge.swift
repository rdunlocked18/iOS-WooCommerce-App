import UIKit
import SDWebImage
import FeedKit

class PostCellLarge: UICollectionViewCell, PostCell {
    
    public static var widthHeightRatio = 0.60
    public static var widthHeightRatioRelated = 1.5
    public static var widthHeightRatioRelatedVideo = 0.7
    public static let identifier = "PostCellLarge"
    
    @IBOutlet fileprivate weak var containerView: UIView!
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var captionLabel: UILabel!
    @IBOutlet fileprivate weak var commentLabel: UILabel!
    
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
                commentLabel.text = item.pubDate!.toString()
            }
        }
    }
    
    var video: Video? {
        didSet {
            if let item = video {
                imageView.sd_setImage(with: URL(string: (item.snippet.thumbnails.high.url)!))
                captionLabel.text = String(htmlEncodedString: (item.snippet.title)!)
                commentLabel.text = item.snippet.publishedAt
            }
        }
    }
    
    var audio: SoundCloudSong? {
        didSet { }
        //STUB
    }
    
}
