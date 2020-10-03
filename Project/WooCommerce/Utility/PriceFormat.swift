//
//  PriceFormat.swift
//  Universal
//
//  Created by Mark on 06/03/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation

public func formatPrice(value: Float) -> String {
    return String(format: "%@%.02f", currency, value)
}
