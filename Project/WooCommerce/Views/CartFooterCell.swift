import UIKit

final class CartFooterCell: UIView {

    // MARK: Properties

    @IBOutlet private weak var totalItemsLabel: UILabel!

    @IBOutlet private weak var totalPriceLabel: UILabel!

    @IBOutlet private weak var payButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        payButton.layer.masksToBounds = false
        payButton.layer.cornerRadius = 6

        //self.contentView.drawTopBorderWithColor(color: UIColor.brown, height: 0.5)
    }

    func configureWithCart(cart: Cart) {
        // Assign the labels. 
        if (cart.productCount() > 1) {
            totalItemsLabel.text = "\(cart.productCount()) " + NSLocalizedString("items", comment: "")
        } else {
            totalItemsLabel.text = NSLocalizedString("item_one", comment: "")
        }
        totalPriceLabel.text = formatPrice(value:cart.totalAmount())
    }

}

extension UIView {
    // Draw a border at the top of a view.
    func drawTopBorderWithColor(color: UIColor, height: CGFloat) {
        let topBorder = CALayer()
        topBorder.backgroundColor = color.cgColor
        topBorder.frame = CGRect(origin: .zero, size: CGSize(width: self.bounds.width, height: height))
        self.layer.addSublayer(topBorder)
    }
}

