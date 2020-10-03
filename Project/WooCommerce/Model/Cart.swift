import Foundation
import LPSnackbar

final class Cart {
    static let sharedInstance = Cart()

    static let cartUpdatedNotificationName = "com.sherdle.ios.cart.updated.notification"

    var items: [CartItem] = [] {
        didSet {
            postCartUpdatedNotification()
        }
    }

    init() {
    }

    init(items: [CartItem]) {
        self.items = items
    }

    func productCount() -> Int {
        var count = 0
        for item in items {
            count += item.quantity
        }
        return count
    }

    func subtotalAmount() -> Float {
        return items.map { $0.price }.reduce(0, +)
    }

    func totalAmount() -> Float {
        return subtotalAmount()
    }
    
    func updateQuantity(item: CartItem, value: Int) -> Bool {
        //If we are adding an item
        if (item.quantity < value && isInStock(product: item.product, variation: item.variation, cartItem: item)) {
            item.quantity = value
            return true
        //If we are removing an item
        } else if (item.quantity > value){
            item.quantity = value
            return true
        }
        return false
    }
    
    func addProduct(product: WooProduct, controller: UINavigationController) {
        addProduct(product: product, variation: nil, controller: controller)
    }

    func addProduct(product: WooProduct, variation: WooProductVariation?, controller: UINavigationController) {
        
        if ((product.externalURL != nil) && ((product.externalURL?.scheme) != nil) && ((product.externalURL?.host) != nil)){
            AppDelegate.openUrl(url: product.externalURL?.absoluteString, withNavigationController: controller)
            return
        }
        
        if (product.variations!.count > 0 && variation == nil){
            promptVariation(product: product, controller: controller)
            return
        }
        
        // Check if the product is already part of the cart.
        var existingCartItem: CartItem?
        for cartItem in items {
            if (cartItem.product.id == product.id && cartItem.variation?.id == variation?.id) {
                existingCartItem = cartItem
                break
            }
        }
        
        let inStock = isInStock(product: product, variation: variation, cartItem: existingCartItem)
        if (inStock) {
            if let existingCartItem = existingCartItem {
                existingCartItem.quantity += 1
            } else {
                items.append(CartItem(product: product, variation: variation))
            }
        }
        
        if (inStock) {
            let snack = LPSnackbar(title: NSLocalizedString("cart_notification_text", comment: ""), buttonTitle: NSLocalizedString("cart_notification_action", comment: ""))
            snack.show(animated: true) { (cart) in
                if cart {
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let cartController = storyBoard.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
                    controller.pushViewController(cartController, animated: true)
                }
            }
        } else {
            LPSnackbar.showSnack(title: NSLocalizedString("cart_notification_out_of_stock", comment: ""))
        }
    }
    
    private func promptVariation(product: WooProduct, controller: UINavigationController){
        
        let loadingMenu = UIAlertController(title: nil, message: NSLocalizedString("loading_variations", comment: ""), preferredStyle: .actionSheet)
        
        if let wPPC = loadingMenu.popoverPresentationController {
            wPPC.sourceView = controller.view
            wPPC.permittedArrowDirections = UIPopoverArrowDirection()
            wPPC.sourceRect = CGRect(x: controller.view.bounds.midX, y: controller.view.bounds.midY, width: 0, height: 0)
        }
        
        controller.present(loadingMenu, animated: true, completion: nil)
        
        WooProduct.getVariations(from: product) { (success, results, error) in
            
            if let error = error {
                print("result: ", results ?? "");
                print("Error searching : \(error)")
                loadingMenu.dismiss(animated: true, completion: nil)
                return
            }
            
            if let results = results {
            
                let optionMenu = UIAlertController(title: nil, message: NSLocalizedString("choose_variations", comment: ""), preferredStyle: .actionSheet)
                
                if let wPPC = optionMenu.popoverPresentationController {
                    wPPC.sourceView = controller.view
                    wPPC.permittedArrowDirections = UIPopoverArrowDirection()
                    wPPC.sourceRect = CGRect(x: controller.view.bounds.midX, y: controller.view.bounds.midY, width: 0, height: 0)
                }
                
                for result in results {
                    let variationAction = UIAlertAction(title: self.getVariationDescription(variation: result), style: UIAlertAction.Style.default, handler: {
                            (alert: UIAlertAction!) -> Void in
                            self.addProduct(product: product, variation: result, controller: controller)
                    })
                    optionMenu.addAction(variationAction)
                }
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
                optionMenu.addAction(cancelAction)
                
                loadingMenu.dismiss(animated: true) {
                    controller.present(optionMenu, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    private func getVariationDescription(variation: WooProductVariation) -> String{
        var attributes = [String]()
        for attribute in variation.attributes! {
            attributes.append(attribute.name! + ": " + attribute.option!)
        }
        attributes.append(formatPrice(value:variation.price!))
        return attributes.joined(separator: ", ")
    }
    
    func isInStock(product: WooProduct, variation: WooProductVariation?, cartItem: CartItem?) -> Bool {
        let inStock = (variation != nil) ? variation?.inStock : product.inStock
        let manageStock = (variation != nil) ? variation?.manageStock : product.manageStock
        let stockQuantity = (variation != nil) ? variation?.stockQuantity : product.stockQuantity

        if (!inStock!) { return false }
        
        if let existingCartItem = cartItem {
            if ((!manageStock! || stockQuantity! > existingCartItem.quantity) &&  existingCartItem.quantity < 10) {
                return true
            }
            return false
        } else {
            return true
        }
    }

    func removeProduct(product: WooProduct) {
        items = items.filter { $0.product.id != product.id }
    }

    func isEmpty() -> Bool {
        return productCount() == 0
    }

    func reset() {
        items = []
    }

    private func postCartUpdatedNotification() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Cart.cartUpdatedNotificationName), object: self)
    }
}
