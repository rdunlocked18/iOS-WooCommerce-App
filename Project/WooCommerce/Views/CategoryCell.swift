import UIKit
import SDWebImage

class CategoryCell: UICollectionViewCell {
    
    public static var widthHeightRatio = 1.0
    
    @IBOutlet fileprivate weak var containerView: UIView!
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var captionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 0
        containerView.layer.masksToBounds = true
    }
    
    var category: WooProductCategory? {
        didSet {
            if let category = category {
                if (category.image != nil) {
                    imageView.sd_setImage(with: category.image!.src);
                }
                captionLabel.text = String(htmlEncodedString: category.name!)
            }
        }
    }
}
