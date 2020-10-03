//
//  RearViewCell.swift
//  Universal
//
//  Created by Mark on 26/09/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation

class RearViewCell : UITableViewCell {

    static let SELECTED_COLOR = UIColor(red: 0.0, green: 66.0/255.0, blue: 117.0/255.0, alpha: 0.2)
    
    override func awakeFromNib() {
        //self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        self.textLabel?.textColor = AppDelegate.MENU_TEXT_COLOR

        let bgColorView:UIView! = UIView()
        bgColorView.backgroundColor = RearViewCell.SELECTED_COLOR
        self.selectedBackgroundView = bgColorView
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        self.imageView?.image = nil
        super.prepareForReuse()
    }

    func setSelected(selected:Bool, animated:Bool) {
        super.setSelected(selected, animated:animated)

        // Configure the view for the selected state
    }
}
