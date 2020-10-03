import Foundation
import ObjectMapper

/// The object representing a Product downloaded from WooCommerce.
public class WooProduct: Mappable {
    
    /// Unique identifier for the resource.
    var id: Int?
    
    /// Product name.
    var name: String?
    
    /// Product slug.
    var slug: String?
    
    /// Product URL.
    var permalink: URL?
    
    /// The date the product was created, in the site’s timezone.
    var dateCreated: Date?
    
    /// The date the product was created, as GMT.
    var dateCreatedGMT: Date?
    
    /// The date the product was last modified, in the site’s timezone.
    var dateModified: Date?
    
    /// The date the product was last modified, as GMT.
    var dateModifiedGMT: Date?
    
    /// Product type. Options: simple, grouped, external and variable. Default is simple.
    var type: WooProductType? = .simple
    
    /// Product status (post status). Options: draft, pending, private and publish. Default is publish.
    var status: String?
    
    /// Featured product. Default is false.
    var featured: Bool? = false
    
    /// Catalog visibility. Options: visible, catalog, search and hidden. Default is visible.
    var catalogVisibility: WooProductCatalogVisibility? = .visible
    
    /// Product description.
    var productDescription: String?
    
    /// Product short description.
    var shortDescription: String?
    
    /// Unique identifier.
    var sku: String?
    
    /// Current product price.
    var price: Float?
    
    /// Product regular price.
    var regularPrice: Float?
    
    /// Product sale price.
    var salePrice: Float?
    
    /// Start date of sale price, in the site’s timezone.
    var dateOnSaleFrom: Date?
    
    /// Start date of sale price, as GMT.
    var dateOnSaleFromGMT: Date?
    
    /// End date of sale price, in the site’s timezone.
    var dateOnSaleTo: Date?
    
    /// End date of sale price, in the site’s timezone.
    var dateOnSaleToGMT: Date?
    
    /// Price formatted in HTML.
    var priceHtml: String?
    
    /// Shows if the product is on sale.
    var onSale: Bool?
    
    /// Shows if the product can be bought.
    var purchasable: Bool?
    
    /// Amount of sales.
    var totalSales: Int?
    
    /// If the product is virtual. Default is false.
    var virtual: Bool? = false
    
    /// If the product is downloadable. Default is false.
    var downloadable: Bool? = false
    
    /// List of downloadable files. See ProductDownload class properties
    var downloads: [WooProductDownload]?
    
    /// Number of times downloadable files can be downloaded after purchase. Default is -1.
    var downloadLimit: Int? = -1
    
    /// Number of days until access to downloadable files expires. Default is -1.
    var downloadExpiry: Int? = -1
    
    /// Product external URL. Only for external products.
    var externalURL: URL?
    
    /// Product external button text. Only for external products.
    var buttonText: String?
    
    /// Tax status. Options: taxable, shipping and none. Default is taxable.
    var taxStatus: WooProductTaxStatus? = .taxable
    
    /// Tax class.
    var taxClass: String?
    
    /// Stock management at product level. Default is false.
    var manageStock: Bool? = false
    
    /// Stock quantity.
    var stockQuantity: Int?
    
    /// Controls whether or not the product is listed as “in stock” or “out of stock” on the frontend. Default is true.
    var inStock: Bool? = true
    
    /// If managing stock, this controls if backorders are allowed. Options: no, notify and yes. Default is no.
    var backorders: WooProductBackorder? = .no
    
    /// Shows if backorders are allowed.
    var backordersAllowed: Bool?
    
    /// Shows if the product is on backordered.
    var backordered: Bool?
    
    /// Allow one item to be bought in a single order. Default is false.
    var soldIndividually: Bool? = false
    
    /// Product weight.
    var weight: String?
    
    /// Product dimensions. See ProductDimensions class properties
    var dimensions: WooProductDimensions?
    
    /// Shows if the product need to be shipped.
    var shippingRequired: Bool?
    
    /// Shows whether or not the product shipping is taxable.
    var shippingTaxable: Bool?
    
    /// Shipping class slug.
    var shippingClass: String?
    
    /// Shipping class ID.
    var shippingClassId: Int?
    
    /// Allow reviews. Default is true.
    var reviewsAllowed: Bool? = true
    
    /// Reviews average rating.
    var averageRating: String?
    
    /// Amount of reviews that the product have.
    var ratingCount: Int?
    
    /// List of related products IDs.
    var relatedIds: [Int]?
    
    /// List of up-sell products IDs.
    var upsellIds: String?
    
    /// List of cross-sell products IDs.
    var crossSellIds: String?
    
    /// Product parent ID.
    var parentId: Int?
    
    /// Optional note to send the customer after purchase.
    var purchaseNote: String?
    
    /// List of categories. See InternalProductCategory class properties.
    var categories: [WooInternalProductCategory]?
    
    /// List of tags. See  properties
    var tags: [WooProductTag]?
    
    /// List of images. See ProductImage class properties
    var images: [WooProductImage]?
    
    /// List of attributes. See ProductAttribute struct properties
    var attributes: [WooProductAttribute]?
    
    /// Defaults variation attributes. See ProductAttribute struct properties
    var defaultAttributes: [WooProductAttribute]?
    
    /// List of variations IDs.
    var variations: [Int]?
    
    /// List of grouped products ID.
    var groupedProducts: [String]?
    
    /// Menu order, used to custom sort products.
    var menuOrder: Int?
    
    /// Meta data. See Product - Meta data properties
    var metaData: [WooProductMetaData]?

    public required init?(map: Map) {}

    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        slug <- map["slug"]
        permalink <- (map["permalink"], using: URLTransform())
        dateCreated <- (map["date_created"], using: ISO8601DateTransform())
        dateCreatedGMT <- (map["date_created_gmt"], using: ISO8601DateTransform())
        dateModified <- (map["date_modified"], using: ISO8601DateTransform())
        dateModifiedGMT <- (map["date_modified_gmt"], using: ISO8601DateTransform())
        type <- map["type"]
        status <- map["status"]
        featured <- map["featured"]
        catalogVisibility <- map["catalog_visibility"]
        productDescription <- map["description"]
        shortDescription <- map["short_description"]
        sku <- map["sku"]
        price <- (map["price"], FloatTransform())
        regularPrice <- (map["regular_price"], FloatTransform())
        salePrice <- (map["sale_price"], FloatTransform())
        dateOnSaleFrom <- (map["date_on_sale_from"], using: ISO8601DateTransform())
        dateOnSaleFromGMT <- (map["date_on_sale_from_gmt"], using: ISO8601DateTransform())
        dateOnSaleTo <- (map["date_on_sale_to"], using: ISO8601DateTransform())
        dateOnSaleToGMT <- (map["date_on_sale_to_gmt"], using: ISO8601DateTransform())
        priceHtml <- map["price_html"]
        onSale <- map["on_sale"]
        purchasable <- map["purchasable"]
        totalSales <- map["total_sales"]
        virtual <- map["virtual"]
        downloadable <- map["downloadable"]
        downloads <- map["downloads"]
        downloadLimit <- map["download_limit"]
        downloadExpiry <- map["download_expiry"]
        externalURL <- (map["external_url"], using: URLTransform())
        buttonText <- map["button_text"]
        taxStatus <- map["tax_status"]
        taxClass <- map["tax_class"]
        manageStock <- map["manage_stock"]
        stockQuantity <- map["stock_quantity"]
        inStock <- map["in_stock"]
        backorders <- map["backorders"]
        backordersAllowed <- map["backorders_allowed"]
        backordered <- map["backordered"]
        soldIndividually <- map["sold_individually"]
        weight <- map["weight"]
        dimensions <- map["dimensions"]
        shippingRequired <- map["shipping_required"]
        shippingTaxable <- map["shipping_taxable"]
        shippingClass <- map["shipping_class"]
        shippingClassId <- map["shipping_class_id"]
        reviewsAllowed <- map["reviews_allowed"]
        averageRating <- map["average_rating"]
        ratingCount <- map["rating_count"]
        relatedIds <- map["related_ids"]
        upsellIds <- map["upsell_ids"]
        crossSellIds <- map["cross_sell_ids"]
        parentId <- map["parent_id"]
        purchaseNote <- map["purchase_note"]
        categories <- map["categories"]
        tags <- map["tags"]
        images <- map["images"]
        attributes <- map["attributes"]
        defaultAttributes <- map["default_attributes"]
        variations <- map["variations"]
        groupedProducts <- map["grouped_products"]
        menuOrder <- map["menu_order"]
        metaData <- map["meta_data"]
    }
    
    public static func get<T: WooProduct>(id: Int,
                           complete: @escaping WooCompletion.Object<T>) {
        WooOS.main.api.getObject(type: .GetProduct(id), then: complete)
    }

    public static func getList<T: WooProduct>(by category: WooProductCategory,
                                              with parameters: [WooProductRequestParameter]? = nil,
                                              then complete: @escaping WooCompletion.Array<T>) {
        guard let safeID = category.id else { return }
        let parameters = WooRequestParameters.Array(type: .GetAllProductsInCategory(safeID), parameters: ["per_page": String(30), "status": "publish"])
        WooOS.main.api.getList(with: parameters, then: complete)
    }
    
    public static func getList<T: WooProduct>(with parameters: [WooProductRequestParameter]? = nil,
                                              then complete: @escaping WooCompletion.Array<T>) {
        var params = ["per_page": String(30), "status": "publish"]
        for param in parameters!{
            params.updateValue(param.parameterTuple.1, forKey: param.parameterTuple.0)
        }
        let parameters = WooRequestParameters.Array(type: .GetAllProducts, parameters: params)
        WooOS.main.api.getList(with: parameters, then: complete)
    }
    
    public static func getVariations<T: WooProductVariation>(from product: WooProduct,
                                     and complete: @escaping WooCompletion.Array<T>) {
        guard let safeID = product.id else {
            complete(false, nil, "ID of product is nil. Very bad, very bad.")
            return
        }
        
        let parameters = WooRequestParameters.Array(type: .GetVariationsOfProduct(safeID), parameters: ["per_page": String(30)])
        WooOS.main.api.getList(with: parameters, then: complete)
    }
}


public enum WooRequestContext: String {
    case view = "view"
    case edit = "edit"
}

public enum WooProductType: String {
    case simple = "simple"
    case grouped = "grouped"
    case external = "external"
    case variable = "variable"
}

public enum WooProductStatus: String {
    case draft = "draft"
    case pending = "pending"
    case `private` = "private"
}

public enum WooProductCatalogVisibility: String {
    case visible = "visible"
    case catalog = "catalog"
    case search = "search"
    case hidden = "hidden"
}

public class WooProductDownload: Mappable {
    
    /// File MD5 hash.
    var id: String?
    
    /// File name.
    var name: String?
    
    /// File URL.
    var file: URL?
    
    public required init?(map: Map) { }
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        file <- (map["file"], using: URLTransform())
    }
}

struct WooInternalProductCategory: Mappable {
    
    /// Category ID.
    var id: Int?
    
    /// Category name.
    var name: String?
    
    /// Category slug.
    var slug: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        slug <- map["slug"]
    }
}

struct WooProductTag: Mappable {
    
    /// Tag ID.
    var id: Int?
    
    /// Tag name.
    var name: String?
    
    /// Tag slug.
    var slug: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        slug <- map["slug"]
    }
}
