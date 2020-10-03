//
//  FrontNavigationController.swift
//  Universal
//
//  Created by Mark on 24/09/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation

class FrontNavigationController : UITabBarController, UITabBarControllerDelegate, ConfigParserDelegate {
    
    var prevShadowColor:UIColor!
    var selectedIndexPath:IndexPath!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prevShadowColor = self.revealViewController().frontViewShadowColor
        self.tabBar.isTranslucent = false
        self.tabBar.tintColor = AppDelegate.APP_THEME_COLOR
        if (!AppDelegate.APP_THEME_LIGHT) {
            self.tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.6)
            self.tabBar.tintColor = UIColor.white
            self.tabBar.barTintColor = AppDelegate.APP_THEME_COLOR
        }
        
        if (selectedIndexPath == nil) {
            selectedIndexPath  = IndexPath(row: 0, section:0)
        }
        
        var viewControllers = [UIViewController]()
        if Config.config == nil {
            //Load loading view
            let controller:TabNavigationController! = self.loadingController()
            controller.viewControllers[0].hidesBottomBarWhenPushed = true
            viewControllers.append(controller)
            self.viewControllers = viewControllers
            //Parse config
            let configParser:ConfigParser! = ConfigParser()
            configParser.delegate = self
            configParser.parseConfig(file: AppDelegate.CONFIG)
            return
        } else {
            let section = Config.config![selectedIndexPath.section]
            let item = section.items![selectedIndexPath.row]
            
            let tabs = item.tabs!
            if tabs.count > 1 {
                
                if  tabs.count <= 5 {
                    for tab in tabs {
                        let controller:TabNavigationController! = self.controllerFromItem(item: tab)
                        viewControllers.append(controller)
                    }
                } else {
                    
                    for tab in tabs[0...3] {
                        let controller:TabNavigationController! = self.controllerFromItem(item: tab)
                        viewControllers.append(controller)
                    }
                    
                    let subTabs = Array(tabs[4...(tabs.count - 1)])
                    let controller:TabNavigationController! = self.moreControllerFromItems(items: subTabs)
                    viewControllers.append(controller)
                }
                
            } else {
                let controller:TabNavigationController! = self.controllerFromItem(item: tabs[0])
                controller.viewControllers[0].hidesBottomBarWhenPushed = true
                viewControllers.append(controller)
            }
            
            self.viewControllers = viewControllers
        }
        
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        (UIApplication.shared.delegate as! AppDelegate).showInterstitial(controller: self)
    }
    
    func parseSuccess(result: [Section]!) {
        Config.setConfig(configToSet: result)
        self.viewDidLoad()
    }
    
    func parseOverviewSuccess(result: [Tab]!) {
        //Unused
    }
    
    func parseFailed(error: Error!) {
        let alertController:UIAlertController! = UIAlertController(title: NSLocalizedString("error", comment: ""),message:AppDelegate.NO_CONNECTION_TEXT, preferredStyle:UIAlertController.Style.alert)
        
        let retry:UIAlertAction! = UIAlertAction(title: NSLocalizedString("retry", comment: ""), style:UIAlertAction.Style.default,
                                                 handler:{ (action:UIAlertAction!) in
                                                    let configParser:ConfigParser! = ConfigParser()
                                                    configParser.delegate = self
                                                    configParser.parseConfig(file: AppDelegate.CONFIG)
        })
        alertController.addAction(retry)
        self.present(alertController, animated:true, completion:nil)
    }
    
    func controllerFromItem(item:Tab!) -> TabNavigationController! {
        let controller = FrontNavigationController.createViewController(item: item, withStoryboard:self.storyboard)!
        
        var tabImage: UIImage?
        if let icon = item.icon, icon.count > 0 {
            tabImage = UIImage(named: icon)
        } else {
            tabImage = UIImage()
        }
        
        let tabItem = UITabBarItem(title:item.name, image:tabImage, selectedImage:tabImage)
        controller.tabBarItem = tabItem
        
        let tabNavigationController = self.storyboard!.instantiateViewController(withIdentifier: "TabNavigationController") as! TabNavigationController
        
        tabNavigationController.viewControllers.append(controller)
        tabNavigationController.configureViewController(viewController: controller)
        return tabNavigationController
    }
    
    func moreControllerFromItems(items:[Tab]!) -> TabNavigationController! {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "MoreViewController") as! MoreViewController
        controller.items = items
        controller.title = NSLocalizedString("more", comment:"")
        
        let tabImage = UIImage(named: "more")
        
        let tabItem = UITabBarItem(title:NSLocalizedString("more", comment: ""), image:tabImage, selectedImage:tabImage)
        controller.tabBarItem = tabItem
        
        let tabNavigationController = self.storyboard!.instantiateViewController(withIdentifier: "TabNavigationController") as! TabNavigationController
        
        tabNavigationController.viewControllers.append(controller)
        tabNavigationController.configureViewController(viewController: controller)
        return tabNavigationController
    }
    
    func loadingController() -> TabNavigationController! {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "LoadingViewController")
        controller.title = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        
        let tabItem = UITabBarItem(title:NSLocalizedString("more", comment: ""), image:nil, selectedImage:nil)
        controller.tabBarItem = tabItem
        
        let tabNavigationController = self.storyboard!.instantiateViewController(withIdentifier: "TabNavigationController") as! TabNavigationController
        
        tabNavigationController.viewControllers.append(controller)
        return tabNavigationController
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    class func createViewController(item:Tab!, withStoryboard storyboard:UIStoryboard!) -> UIViewController! {
        let SOCIAL_ITEMS_NAME = item.name!
        let SOCIAL_ITEMS_TYPE = item.type!
        let SOCIAL_ITEMS_PARAMS = item!.params! as NSArray //TODO Make everything [String]
        
        var controller:UIViewController!
        
        if SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("youtube") == .orderedSame {
            controller = (storyboard.instantiateViewController(withIdentifier: "YoutubeSwiftViewController") as! YoutubeSwiftViewController)
            
            (controller as! YoutubeSwiftViewController).params = SOCIAL_ITEMS_PARAMS
        } else if SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("maps") == .orderedSame {
            controller = (storyboard.instantiateViewController(withIdentifier: "MapsViewController") as! MapsViewController)
            
            (controller as! MapsViewController).params = SOCIAL_ITEMS_PARAMS
        } else if SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("radio")  == .orderedSame {
            controller = (storyboard.instantiateViewController(withIdentifier: "RadioSwiftViewController") as! RadioSwiftViewController)
            
            (controller as! RadioSwiftViewController).params = SOCIAL_ITEMS_PARAMS
        } else if SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("stream")  == .orderedSame {
            controller = (storyboard.instantiateViewController(withIdentifier: "TvViewController") as! TvViewController)
            
            (controller as! TvViewController).params = SOCIAL_ITEMS_PARAMS
        } else if SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("webview")  == .orderedSame {
            controller = (storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewSwiftController)
            
            (controller as! WebViewSwiftController).params = SOCIAL_ITEMS_PARAMS
        }  else if SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("rss")  == .orderedSame {
            controller = (storyboard.instantiateViewController(withIdentifier: "RssSwiftViewController") as! RssSwiftViewController)
            
            (controller as! RssSwiftViewController).params = SOCIAL_ITEMS_PARAMS
        }  else if SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("twitter")  == .orderedSame {
            controller = (storyboard.instantiateViewController(withIdentifier: "SocialViewController") as! SocialViewController)
            
            (controller as! SocialViewController).provider = NSNumber(integerLiteral: 4)
            (controller as! SocialViewController).params = SOCIAL_ITEMS_PARAMS as NSArray
        }  else if SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("facebook")  == .orderedSame {
            controller = (storyboard.instantiateViewController(withIdentifier: "SocialViewController") as! SocialViewController)
            
            (controller as! SocialViewController).provider = NSNumber(integerLiteral: 1)
            (controller as! SocialViewController).params = SOCIAL_ITEMS_PARAMS
        }  else if SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("instagram")  == .orderedSame {
            controller = (storyboard.instantiateViewController(withIdentifier: "SocialViewController") as! SocialViewController)
            
            (controller as! SocialViewController).provider = NSNumber(integerLiteral: 2)
            (controller as! SocialViewController).params = SOCIAL_ITEMS_PARAMS
        }  else if SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("pinterest")  == .orderedSame {
            controller = (storyboard.instantiateViewController(withIdentifier: "SocialViewController") as! SocialViewController)
            
            (controller as! SocialViewController).provider = NSNumber(integerLiteral: 3)
            (controller as! SocialViewController).params = SOCIAL_ITEMS_PARAMS
        }   else if SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("soundcloud")  == .orderedSame || SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("wordpress_audio")  == .orderedSame {
            controller = (storyboard.instantiateViewController(withIdentifier: "AudioViewController") as! AudioViewController)
            
            (controller as! AudioViewController).params = SOCIAL_ITEMS_PARAMS
            (controller as! AudioViewController).isWordpress = SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("wordpress_audio")  == .orderedSame
        }   else if SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("tumblr")  == .orderedSame || SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("flickr")  == .orderedSame {
            controller = (storyboard.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController)
            
            (controller as! PhotosViewController).params = SOCIAL_ITEMS_PARAMS
            (controller as! PhotosViewController).isTumblr = SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("tumblr")  == .orderedSame
        }   else if SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("overview")  == .orderedSame {
            controller = (storyboard.instantiateViewController(withIdentifier: "OverviewSwiftController") as! OverviewSwiftController)
            
            (controller as! OverviewSwiftController).params = SOCIAL_ITEMS_PARAMS
        }   else if SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("woocommerce")  == .orderedSame {
            //            controller = (storyboard.instantiateViewController(withIdentifier: "WooCommerceViewController") as! WooCommerceViewController)
            //            (controller as! WooCommerceViewController).params = SOCIAL_ITEMS_PARAMS
            
            controller = (storyboard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController)
            (controller as! DashboardViewController).params = SOCIAL_ITEMS_PARAMS
        }   else if SOCIAL_ITEMS_TYPE.caseInsensitiveCompare("wordpress")  == .orderedSame {
            controller = (storyboard.instantiateViewController(withIdentifier: "WordpressSwiftViewController") as! WordpressSwiftViewController)
            
            (controller as! WordpressSwiftViewController).params = SOCIAL_ITEMS_PARAMS
        }   else {
            NSLog("Invalid Content Provider: %@", SOCIAL_ITEMS_TYPE)
        }
        
        controller.title = SOCIAL_ITEMS_NAME
        
        return controller
    }
}
