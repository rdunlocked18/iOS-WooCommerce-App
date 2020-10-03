//
//  NavbarGradientView.swift
//  Universal
//
//  Created by Mark on 20/09/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation

class CustomNavigationBar : UINavigationBar {
    
    var backgroundView:UIView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let barFrame = self.frame
        self.backgroundView?.frame = CGRect(x: 0, y: 0, width: barFrame.size.width, height: barFrame.origin.y + barFrame.size.height)
    }
}
