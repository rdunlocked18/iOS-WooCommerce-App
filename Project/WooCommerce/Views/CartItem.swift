import Foundation

class CartItem {

    var product: WooProduct
    var variation: WooProductVariation?
    var quantity: Int = 0

    init(product: WooProduct, variation: WooProductVariation?) {
        self.product = product
        self.variation = variation
        self.quantity = 1
    }

    init(product: WooProduct, variation: WooProductVariation?, quantity: Int) {
        self.product = product
        self.variation = variation
        self.quantity = quantity
    }

    var price: Float {
        return ((variation == nil) ? self.product.price! : self.variation!.price!) * Float(self.quantity)
    }

}
