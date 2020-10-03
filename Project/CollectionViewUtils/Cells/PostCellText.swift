import UIKit
import SDWebImage
import FeedKit

class PostCellText: UICollectionViewCell, PostCell {
    
    public static let identifier = "PostCellText"
        
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var post: WPPost? {
        didSet {
            if let post = post {
                captionLabel.text = String(htmlEncodedString: post.title!)
                commentLabel.text = post.date
            }
        }
    }
    
    var item: RSSFeedItem? {
        didSet {
            if let item = item {
                captionLabel.text = String(htmlEncodedString: item.title!)
                commentLabel.text = item.pubDate!.toString()
            }
        }
    }
    
    var video: Video? {
        didSet {
            if let item = video {
                captionLabel.text = String(htmlEncodedString: (item.snippet.title)!)
                commentLabel.text = item.snippet.publishedAt
            }
        }
    }
    
    var audio: SoundCloudSong? {
        didSet {
            if let item = audio {
                captionLabel.text = String(htmlEncodedString: (item.title))

                commentLabel.text = (item.duration != nil) ? String(format: NSLocalizedString("audio_subtitle", comment: ""), item.userName, item.duration!.makeMilisecondsRedeable()) : item.userName
            }
        }
    }
    
}
