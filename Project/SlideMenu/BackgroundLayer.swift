//
//  BackgroundLayer.swift
//  Universal
//
//  Created by Mark on 26/09/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation

class BackgroundLayer : NSObject {

//Blue gradient background
    @objc class func colorGradient() -> CAGradientLayer! {
        let colorOne:UIColor! = AppDelegate.GRADIENT_ONE
        let colorTwo:UIColor! = AppDelegate.GRADIENT_TWO

        let colors:[CGColor]! = [colorOne.cgColor, colorTwo.cgColor]

        let stopOne:NSNumber! = NSNumber(value: 0)
        let stopTwo:NSNumber! = NSNumber(value: 1)

        let locations:[NSNumber]! = [stopOne, stopTwo]

        let headerLayer:CAGradientLayer! = CAGradientLayer()
        headerLayer.colors = colors
        headerLayer.locations = locations

        return headerLayer

    }
}
