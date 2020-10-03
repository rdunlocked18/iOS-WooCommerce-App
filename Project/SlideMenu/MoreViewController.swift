//
//  MoreViewController.swift
//  Universal
//
//  Created by Mark on 24/09/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation
import UIKit;

class MoreViewController : UITableViewController {

    // MARK: - View Life Cycle

    var items:[Tab]!
    private var timeZoneNames:[AnyObject]!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return self.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let MyIdentifier:String! = "MyIdentifier" 
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: MyIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier:MyIdentifier)
        }

        // Set up the cell.
        let item = self.items![indexPath.row]
        let controllerTitle:String! = item.name
        cell.textLabel!.text = controllerTitle

        return cell
    }

    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let item:Tab! = self.items![indexPath.row]
        let controller:UIViewController! = FrontNavigationController.createViewController(item: item, withStoryboard:self.storyboard)

        self.navigationController!.pushViewController(controller, animated:true)
    }
}
