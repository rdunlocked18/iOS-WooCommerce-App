//
//  NavbarGradientView.swift
//  Universal
//
//  Created by Mark on 20/09/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation

class NavbarGradientView: UIView {
    private var isTransparent = false
    
    @IBOutlet var plainView: UIView!
//    @IBOutlet weak var translucentView: ILTranslucentView!{
//        didSet{
//
//            self.translucentView.translucentAlpha = 1
//            self.translucentView.translucentStyle = UIBarStyle.default
//            self.translucentView.translucentTintColor = AppDelegate.APP_THEME_LIGHT ? UIColor.white : AppDelegate.APP_THEME_COLOR
//            self.translucentView.backgroundColor = UIColor.clear
//
//            if AppDelegate.APP_BAR_SHADOW {
//                self.translucentView.layer.shadowColor = UIColor.black.cgColor
//                self.translucentView.layer.shadowOffset = CGSize(width: 0, height: 1)
//                self.translucentView.layer.shadowRadius = 5.0
//                self.translucentView.layer.shadowOpacity = 0.5
//            }
//
//        }
//    }
//
    @objc func turnTransparency(on: Bool, animated: Bool, tabController controller: UIViewController?) {
        //Update navigationBar text color
        (controller as? TabNavigationController)?.forceDarkNavigation(force: on)
        
        if on == isTransparent {
            return // already in that state
        }
        
        isTransparent = on
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                self.plainView.alpha = on ? 0 : 1
            }) { finished in
            }
        } else {
            plainView.alpha = on ? 0 : 1
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let lightGradientColor = UIColor.black.withAlphaComponent(0.7)
        let darkGradientColor = UIColor.clear
        
        let locations: [CGFloat] = [0.0, 1.0]
        let colors = [lightGradientColor.cgColor, darkGradientColor.cgColor] as CFArray
        
        let colorSpc = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpc, colors: colors, locations: locations)
        
        context?.drawLinearGradient(gradient!, start: CGPoint(x: bounds.midX, y: bounds.minY), end: CGPoint(x: bounds.midX, y: bounds.maxY), options: .drawsAfterEndLocation) //Adjust second point according to your view height
    }

}
