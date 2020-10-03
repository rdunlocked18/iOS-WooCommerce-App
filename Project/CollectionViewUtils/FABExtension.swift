//
//  FABExtension.swift
//  Universal
//
//  Created by Mark on 16/01/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation


extension UIView {
    /*
     * Makes a UIView rounded, with gradient background and elevation
     * Any objects that this view contains, or any backgrounds, will be lost
     */
    public func round() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowRadius = CGFloat(6)
        self.layer.shadowOpacity = 0.24
        self.backgroundColor = nil
        
        let colors = [AppDelegate.GRADIENT_TWO.cgColor, AppDelegate.GRADIENT_ONE.cgColor]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        gradientLayer.colors = colors as [Any]
        gradientLayer.cornerRadius = min(self.frame.size.width, self.frame.size.height) / 2
        gradientLayer.locations = [0.0,0.7]
        self.layer.addSublayer(gradientLayer)
    }
    
}
