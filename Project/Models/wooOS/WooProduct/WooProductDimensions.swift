//
//  WooProductDimensions.swift
//  Universal
//
//  Created by Mark on 17/03/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

//
//  WooProductImage.swift
//  Eightfold
//
//  Created by brianna on 1/28/18.
//  Copyright © 2018 Owly Design. All rights reserved.
//

import Foundation
import ObjectMapper

public class WooProductDimensions: Mappable {
    
    var height: String?
    var length: String?
    var width: String?
    
    public required init?(map: Map) { }
    
    public func mapping(map: Map) {
        length <- map["length"]
        width <- (map["width"])
        height <- (map["height"])
    }
}

