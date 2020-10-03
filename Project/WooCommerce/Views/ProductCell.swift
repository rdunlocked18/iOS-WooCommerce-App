import UIKit
import SDWebImage

class ProductCell: UICollectionViewCell {
  
  public static var widthHeightRatio = 1
    
  @IBOutlet fileprivate weak var containerView: UIView!
  @IBOutlet fileprivate weak var imageView: UIImageView!
  @IBOutlet fileprivate weak var captionLabel: UILabel!
  @IBOutlet fileprivate weak var commentLabel: UILabel!
  @IBOutlet fileprivate weak var titleLabel: UILabel!
    
  override func awakeFromNib() {
    super.awakeFromNib()
    containerView.layer.cornerRadius = 6
    containerView.layer.masksToBounds = false
  }
  
  var product: WooProduct? {
    didSet {
      if let product = product {
        if (product.images?.isEmpty == false) {
            //imageView.sd_setImage(with: product.images?[0].src);
        }
        print(product)
        captionLabel.text = product.name!
        commentLabel.text = formatPrice(value: product.price!)
        
        if product.price! < product.regularPrice! {
            let retailPriceString = formatPrice(value: product.regularPrice!)
            let currentPriceString = formatPrice(value: product.price!)
            let attributedPrice = NSMutableAttributedString(string: retailPriceString + " " + currentPriceString)
            attributedPrice.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, retailPriceString.count))
            attributedPrice.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.red, range: NSMakeRange(0, retailPriceString.count))
            commentLabel.attributedText = attributedPrice
        }
      }
    }
  }
}
