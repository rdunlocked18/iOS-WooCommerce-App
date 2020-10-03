
import Foundation
import ObjectMapper

public class WooOS {
    
    //  ------------------------
    /// MARK: - Static Variables
    //  ------------------------
    
    /// Shared instance
    public static var main: WooOS!
    
    //  --------------------------------
    /// MARK: - Instance level variables
    //  --------------------------------
    
    /// The main API where all the requests are made from.
    public var api: WooAPI!
    
    // In the future a WooCart object will be here.
    
    /// The stored username of the user that is signed in. If user is not authenticated this value is nil.
    public var username: String?
    
    //  ----------------------
    /// MARK: - Initialization
    //  ----------------------

    /// Initializer used to instantiate the main shared instance.
    ///
    /// - Parameters:
    ///   - url: The base site URL of the WooCommerce store.
    ///   - key: The Consumer Key found in the WooCommerce API settings.
    ///   - secret: The Consumer Secret found in the WooCommerce API settings.
    @discardableResult
    init(url: URL, key: String, secret: String) {
        WooOS.main = self
        let newAPI = WooAPI(url: url, key: key, secret: secret)
        WooOS.main.api = newAPI
    }
}

public class FloatTransform: TransformType {
    public typealias Object = Float
    public typealias JSON = String
    
    public init() {}
    
    public func transformFromJSON(_ value: Any?) -> Float? {
        guard let value = value as? NSString else { return nil }
        return value.floatValue
    }
    
    public func transformToJSON(_ value: Float?) -> String? {
        guard let value = value else { return nil }
        return value.description
    }
}
