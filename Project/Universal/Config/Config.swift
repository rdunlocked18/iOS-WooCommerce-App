//
//  Config.swift
//  Universal
//
//  Created by Mark on 26/09/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation

class Config : NSObject {
    
    static var config:[Section]?

    class func setConfig(configToSet:[Section]!) { config = configToSet }
}
