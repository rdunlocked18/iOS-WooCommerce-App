//
//  RearTableViewController.swift
//  Universal
//
//  Created by Mark on 26/09/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation

class RearTableViewController : UITableViewController {

    private var lblVertLine:UILabel!
    private var cellImgVw:UIImageView!
    private var lblHorizLineBottom:UILabel!
    private var statusBarBackground:UIView!
    var headerView:UIView!
    var selectedIndexPath:IndexPath!
    
    @IBOutlet var footerView: UIView!
    @IBOutlet var aboutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.isNavigationBarHidden = true

        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView.backgroundColor = UIColor.clear

        self.selectedIndexPath = IndexPath(row: 0, section:0)

        //self.config = [Config config];

        if !AppDelegate.ABOUT_TEXT.isEqual("") {

            //UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];

            aboutButton.setTitle(NSLocalizedString("about_button", comment:""),
                                 for:.normal)
            aboutButton.setTitleColor(AppDelegate.MENU_TEXT_COLOR, for:.normal)
            aboutButton.setTitleColor(AppDelegate.MENU_TEXT_COLOR_SECTION, for:.highlighted)
            aboutButton.sizeToFit()
            aboutButton.layer.borderColor = AppDelegate.MENU_TEXT_COLOR.cgColor
            aboutButton.layer.borderWidth = 1.0
            aboutButton.layer.cornerRadius = 15.0
            aboutButton.addTarget(self,
                                  action: #selector(launchAbout),
                                  for:.touchDown)
            self.tableView.tableFooterView = footerView
        }

        if !AppDelegate.APP_DRAWER_HEADER {
            self.tableView.tableHeaderView!.removeFromSuperview()
            self.tableView.tableHeaderView = UIView(frame:CGRect(x: 0.0, y: 0.0, width: self.tableView.bounds.width, height: 1.0))
            self.tableView.reloadData()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        //Hacky way to set toolbar background
        let statusBarSize:CGSize = UIApplication.shared.statusBarFrame.size
        let height:CGFloat = min(statusBarSize.width, statusBarSize.height)
        if (statusBarBackground == nil) {
            statusBarBackground = UIView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height))
            statusBarBackground.backgroundColor = (AppDelegate.APP_THEME_LIGHT) ? UIColor.white : AppDelegate.GRADIENT_ONE
            statusBarBackground.alpha = (AppDelegate.APP_THEME_LIGHT) ? 0.2 : 0.7
            self.navigationController!.view.addSubview(statusBarBackground)
        } else {
            statusBarBackground.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height)
        }

    }

    func unlockAppDialog() {

        let price:String! = WBInAppHelper.priceString(fromProductId: AppDelegate.IN_APP_PRODUCT)

        var buyLabel:String!
        if (price == "Error") {
#if TARGET_OS_SIMULATOR
            //Simulator
            buyLabel = String(format:"%@ %@",NSLocalizedString("buy", comment:""), "(Test)")
#else
            // Device
            buyLabel = "IAP not available"
#endif
        } else {
            buyLabel = String(format:"%@ %@",NSLocalizedString("buy", comment:""), price)
        }


        let alertController:UIAlertController! = UIAlertController(title: NSLocalizedString("purchase_dialog_title", comment:""), message:NSLocalizedString("purchase_dialog_text",comment:""), preferredStyle:.alert)

        alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment:""), style:.default, handler:nil))

        alertController.addAction(UIAlertAction(title: buyLabel, style:.default, handler:{ (action:UIAlertAction!) in
            WBInAppHelper.payProduct(AppDelegate.IN_APP_PRODUCT, resBlock:{ (success:Bool,err:NSError!) in
                    if success {
                        let alertController:UIAlertController! = UIAlertController(title: NSLocalizedString("purchase_dialog_title", comment:""), message:NSLocalizedString("purchase_dialog_text_thanks", comment:""), preferredStyle:.alert)

                        alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment:""), style:.default, handler:nil))

                        DispatchQueue.main.async {
                            self.present(alertController, animated:true, completion:nil)
                        }
                        
                    } else {
                        let alertController:UIAlertController! = UIAlertController(title: NSLocalizedString("purchase_dialog_title", comment:""), message:NSLocalizedString("purchase_dialog_text_fail", comment:""), preferredStyle:.alert)

                        alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment:""), style:.default, handler:nil))

                       DispatchQueue.main.async {
                        self.present(alertController, animated:true, completion:nil)
                        }
                    }
                } as? ActionBlock)
        }))

        alertController.addAction(UIAlertAction(title: NSLocalizedString("purchase_dialog_restore", comment:""), style:.default, handler:{ (action:UIAlertAction!) in
            WBInAppHelper.restorePayments({ (success:Bool,err:NSError!)
                in
                    if success {
                        let alertController:UIAlertController! = UIAlertController(title: NSLocalizedString("purchase_dialog_title", comment:""), message:NSLocalizedString("purchase_dialog_restore_thanks", comment:""), preferredStyle:.alert)

                        alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style:.default, handler:nil))

                       DispatchQueue.main.async {
                        self.present(alertController, animated:true, completion:nil)
                        }
                    } else {
                        let alertController:UIAlertController! = UIAlertController(title: NSLocalizedString("purchase_dialog_title", comment:""), message:NSLocalizedString("purchase_dialog_restore_fail", comment:""), preferredStyle:.alert)

                        alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment:""), style:.default, handler:nil))

                       DispatchQueue.main.async {
                        self.present(alertController, animated:true, completion:nil)
                        }
                    }
                } as? ActionBlock)
        }))


       DispatchQueue.main.async {
        self.present(alertController, animated:true, completion:nil)
        }
    }

    @objc func launchAbout(paramSender:UIButton!) {

        let alertController:UIAlertController! = UIAlertController(title: NSLocalizedString("about_dialog_title", comment:""), message:AppDelegate.ABOUT_TEXT, preferredStyle:.alert)

        alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment:""), style:.default, handler:nil))

        alertController.addAction(UIAlertAction(title: NSLocalizedString("about_open", comment:""), style:.default, handler:{ (action:UIAlertAction!) in
            //let application:UIApplication! = UIApplication.shared
            //application.openURL(NSURL.URLWithString(String(format:"%@",ABOUT_URL)), options:[], completionHandler:nil)
            //TODO: Test:
            UIApplication.shared.open(URL(string: AppDelegate.ABOUT_URL)!)
        }))

        if AppDelegate.IN_APP_PRODUCT.count > 0 && !AppDelegate.hasPurchased()
        {alertController.addAction(UIAlertAction(title: NSLocalizedString("about_purchase", comment:""), style:.default, handler:{ (action:UIAlertAction!) in
                self.unlockAppDialog()
            }))}

        DispatchQueue.main.async {
            self.present(alertController, animated:true, completion:nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }

    func myItemsClicked() {
    }

    func settingBtnClicked() {
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return Config.config!.count
    }

    override func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        let sec:Section! = Config.config![section]
        return sec.items.count
    }

    // item view
    override func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for:indexPath)

        let section:Section! = Config.config![indexPath.section]
        let item:Item! = section.items[indexPath.row]

        cell.textLabel?.text = item.name

        if item.icon != nil {
            cell.imageView?.image = UIImage(named: item.icon)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath == self.selectedIndexPath {
            cell.backgroundColor = RearViewCell.SELECTED_COLOR
        } else {
            cell.backgroundColor = UIColor.clear
        }
        cell.textLabel?.backgroundColor = UIColor.clear
    }

    //table head view
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView = UIView(frame:CGRect(x: 0, y: 0, width: 320, height: 44))

        let lbl:UILabel! = UILabel(frame:CGRect(x: 15, y: 0, width: 300, height: 40))
        lbl.backgroundColor = UIColor.clear
        lbl.font = UIFont.systemFont(ofSize: 18)
        lbl.textColor = AppDelegate.MENU_TEXT_COLOR_SECTION
        let sec:Section! = Config.config![section]
        lbl.text = sec.name

        headerView.addSubview(lbl)

        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (Config.config![section] ).name.isEqual("")
        {
            return CGFloat.leastNormalMagnitude
        }

        return 35
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "showFeed") {
            let indexPath = self.tableView.indexPathForSelectedRow!
            let section:Section! = Config.config![indexPath.section]
            let item:Item! = section.items[indexPath.row]

            let firstTab:Tab! = item.tabs[0]
            if firstTab.type.caseInsensitiveCompare("custom") == .orderedSame {
                let url:String! = firstTab.params[0]
                AppDelegate.openUrl(url: url, withNavigationController:nil)
                self.tableView.reloadRows(at: [indexPath], with:.none)
                return false
            }
            if item.iap && AppDelegate.IN_APP_PRODUCT.count > 0 && !AppDelegate.hasPurchased() {
                self.unlockAppDialog()
                return false
            }
        }
        return true
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (UIApplication.shared.delegate as! AppDelegate).showInterstitial(controller: self)
        if (segue.identifier == "showFeed") {
            let indexPath = self.tableView.indexPathForSelectedRow
            let frontNav = segue.destination as! FrontNavigationController
            frontNav.selectedIndexPath = indexPath

            let rearVC = segue.source as! RearTableViewController
            let oldIndexPath = rearVC.selectedIndexPath!
            rearVC.selectedIndexPath = indexPath

            self.revealViewController().revealToggle(nil)
            self.tableView.reloadRows(at: [oldIndexPath, indexPath!], with:.none)
        }
    }
}
