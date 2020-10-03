import UIKit
import SDWebImage

class PostCategoryCell: UICollectionViewCell {
    
    public static var widthHeightRatio = 0.5
    
    private var gradientLayer = CAGradientLayer()
    
    @IBOutlet fileprivate weak var containerView: UIView!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet fileprivate weak var captionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true
        
        let colors = [AppDelegate.GRADIENT_TWO.cgColor, AppDelegate.GRADIENT_ONE.cgColor]
        
        gradientLayer.colors = colors as [Any]
        gradientLayer.locations = [0.0,0.7]
        grayView.layer.addSublayer(gradientLayer)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.width = ceil(size.width)
        layoutAttributes.frame = frame
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        return layoutAttributes
    }

    var category: WPCategory? {
        didSet {
            if let category = category {
                captionLabel.text = category.name!
                
            }
        }
    }
    
    
}
