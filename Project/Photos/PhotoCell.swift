import UIKit
import SDWebImage
import FeedKit

class PhotoCell: UICollectionViewCell {
    
    public static var widthHeightRatio = 1
    public static let identifier = "PhotoCell"
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.masksToBounds = true
    }
    
    var photo: Photo? {
        didSet {
            if let photo = photo {
                if let image = photo.url_thumbnail {
                    imageView.sd_setImage(with: URL(string: image))
                }
            }
        }
    }
}
