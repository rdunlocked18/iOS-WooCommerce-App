//
//  CardView.swift
//  Universal
//
//  Created by Rohit Daftari on 08/08/20.
//  Copyright © 2020 VRCODEHUB. All rights reserved.
//

import UIKit

class CardView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    
    @IBInspectable var cornerRadius : CGFloat = 10
    @IBInspectable var shadowOffsetW : CGFloat = 0
    @IBInspectable var shadowOffsetH : CGFloat = 5
    @IBInspectable var shadowColor : UIColor = UIColor.lightGray
    @IBInspectable var shadowColorOpac : CGFloat = 0.7
    
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetW, height: shadowOffsetH)
       let  shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowOpacity = Float(shadowColorOpac)
        
        
    }
    
    

}
