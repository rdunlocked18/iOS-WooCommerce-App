//
//  Item.swift
//  Universal
//
//  Created by Mark on 26/09/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation

class Item : Codable {
    var name:String!
    var icon:String!
    var iap = false
    var tabs:[Tab]!
}

