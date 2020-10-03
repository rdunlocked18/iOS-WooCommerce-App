//
//  AppDelegate.swift
//  Universal
//
//  Created by Mark on 29/09/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADInterstitialDelegate {
    
    //START OF CONFIGURATION
    
    static let CONFIG = "config"
    
    /**
     * Layout options
     */
    static let APP_THEME_LIGHT = false
    static let APP_THEME_COLOR = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0)
    static let APP_BAR_SHADOW = true
    
    static let GRADIENT_ONE = UIColor(red: 0.86, green: 0.14, blue: 0.00, alpha: 1.00)
    static let GRADIENT_TWO = UIColor(red: 0.86, green: 0.14, blue: 0.00, alpha: 1.00)
    static let APP_DRAWER_HEADER = true
    static let MENU_TEXT_COLOR = UIColor.white
    static let MENU_TEXT_COLOR_SECTION = UIColor.lightText
    
    /**
     * About / Texts
     **/
    static let NO_CONNECTION_TEXT = "We weren't able to connect to the server. Make sure you have a working internet connection."
    static let ABOUT_TEXT = "Thank you for downloading our app! \n\nIf you need any help, press the button below to visit our support."
    static let ABOUT_URL = "https://yourgastroapp.com"
    //Clearing both your About Text and About URL will hide the about button
    
    /**
     * Monetization
     **/
    static let INTERSTITIAL_INTERVAL = 5
    static let ADMOB_INTERSTITIAL_ID = ""
    static let BANNER_ADS_ON = false
    static let ADMOB_UNIT_ID = ""
    static let ADMOB_APP_ID = ""
    static let INTERSTITIALS_FOR_WEBVIEW = true
    
    static let IN_APP_PRODUCT = ""
    
    /**
     * API Keys
     **/
    static let ONESIGNAL_APP_ID = "8ec442e5-4822-4c87-9d3a-b3fb96cda04c"
    
    static let MAPS_API_KEY = ""
    
    static let YOUTUBE_CONTENT_KEY = ""
    
    static let TWITTER_API = ""
    static let TWITTER_API_SECRET = ""
    static let TWITTER_TOKEN = ""
    static let TWITTER_TOKEN_SECRET = ""
    
    static let INSTAGRAM_ACCESS_TOKEN = ""
    static let FACEBOOK_ACCESS_TOKEN = ""
    static let PINTEREST_ACCESS_TOKEN = ""
    
    static let SOUNDCLOUD_CLIENT = ""
    
    static let FLICKR_API = ""
    static let TUMBLR_API = ""
    
    /**
     * WooCommerce
     **/
    
    static let WOOCOMMERCE_HOST = "https://yourgastroapp.com"
    static let WOOCOMMERCE_KEY = "ck_e1a76ad29b10ccd89c10add3748cb725f77e9fa4"
    static let WOOCOMMERCE_SECRET = "cs_f22b3316576e7536774e0516c1a405ac63f3194d"
    /**
     * Other
     */
    static let OPEN_IN_BROWSER = false
    static let DISABLED_NAVIGATIONBAR = false
    static let WEBVIEW_HIDE_NAVIGATION = false
    static let HIDING_NAVIGATIONBAR = true
    static let WP_ATTACHMENTS_BUTTON = false
    static let openTargetBlankSafari = false
    static let OPEN_BROWSER: [String] = []
    
    //END OF CONFIGURATION
    
    var window: UIWindow?
    var interstitialCount:Int = 0
    var interstitialAd : GADInterstitial?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        //MARK: - Navigation bar
//        UINavigationBar.appearance().backgroundColor = .red
//        UINavigationBar.appearance().barTintColor = .red
//        UINavigationBar.appearance().tintColor = .white
//        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//        UINavigationBar.appearance().isTranslucent = false
//        UINavigationBar.appearance()
        
        GMSServices.provideAPIKey(AppDelegate.MAPS_API_KEY)
        TvViewController.initPlayer()
        // Ads
        if AppDelegate.BANNER_ADS_ON && !AppDelegate.hasPurchased() {
            let revealController = self.window?.rootViewController as! SWRevealViewController
            
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            CJPAdMobHelper.sharedInstance().adMobUnitID = AppDelegate.ADMOB_UNIT_ID
            CJPAdMobHelper.sharedInstance().start(with: revealController)
            //UIApplication.sharedApplication.delegate?.window.rootViewController = CJPAdMobHelper.sharedInstance()
            
            // Request test ads on devices you specify. Your test device ID is printed to the console when
            // an ad request is made.
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ (kGADSimulatorID as! String), "YourTestDevice" ]
            
            self.window!.rootViewController = CJPAdMobHelper.sharedInstance()
            
            revealController.frontViewController.viewDidLoad()
        }
        
        //In App purchases
        if AppDelegate.IN_APP_PRODUCT.count > 0 {
            WBInAppHelper.setProductsList([AppDelegate.IN_APP_PRODUCT])
        }
        
        // OneSignal/Notifications
        if AppDelegate.ONESIGNAL_APP_ID.count > 0 {
            //self.oneSignal = OneSignal(launchOptions:launchOptions, appId:ONESIGNAL_APP_ID)
            
            let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
            
            OneSignal.initWithLaunchOptions(launchOptions,
                                            appId: AppDelegate.ONESIGNAL_APP_ID,
                                            handleNotificationAction: nil,
                                            settings: onesignalInitSettings)
            
            OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
            
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                print("User accepted notifications: \(accepted)")
            })
        }
        
        return true
    }
    
    private func application(application:UIApplication!, didRegisterForRemoteNotificationsWithDeviceToken deviceToken:NSData!) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(token)
    }
    
    private func application(application:UIApplication!, didFailToRegisterForRemoteNotificationsWithError error:NSError!) {
        NSLog("Failed to get token, error: %= ", error)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //--- Utility for opening urls
    class func openUrl(url:String!, withNavigationController navController:UINavigationController!) {
        if OPEN_IN_BROWSER || (navController == nil) {
            guard let urlV = URL(string: url) else { return }
            UIApplication.shared.open(urlV)
        } else {
            //Make the header/navbar solid
            if (navController is TabNavigationController) {
                let nc = navController as! TabNavigationController
                nc.turnTransparency(on: false, animated: true)
            }
            
            let storyboard:UIStoryboard! = UIStoryboard(name: "Main", bundle:nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewSwiftController
            vc.params = [url!]
            navController.pushViewController(vc, animated:true)
        }
    }
    
    //-- Interstitials
    func reloadInterstitialAd() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: AppDelegate.ADMOB_INTERSTITIAL_ID)
        interstitial.delegate = self
        let request = GADRequest()
        //request.testDevices = [kGADSimulatorID]
        interstitial.load(request)
        return interstitial
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("\(ad) did fail to receive ad with error \(error)")
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.interstitialAd = reloadInterstitialAd()
    }
    
    func showInterstitial(controller: UIViewController) {
        if shouldShowInterstitial() && self.interstitialAd?.isReady ?? false {
            self.interstitialAd?.present(fromRootViewController: self.window!.rootViewController!)
        }
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        self.interstitialAd = ad
    }
    
    func interstitialsEnabled() -> Bool {
        if AppDelegate.ADMOB_INTERSTITIAL_ID.count == 0 {return false}
        if AppDelegate.INTERSTITIAL_INTERVAL == 0 {return false}
        if AppDelegate.hasPurchased() {return false}
        
        return true
    }
    
    func shouldShowInterstitial() -> Bool {
        if !interstitialsEnabled() { return false }
        if self.interstitialAd == nil { self.interstitialAd = reloadInterstitialAd()}
        var shouldShowInterstitial = false
        if interstitialCount == AppDelegate.INTERSTITIAL_INTERVAL {
            shouldShowInterstitial = true
            interstitialCount = 0
        }
        
        interstitialCount += 1
        return shouldShowInterstitial
    }
    
    class func hasPurchased() -> Bool {
        if IN_APP_PRODUCT.count == 0 {return false}
        return WBInAppHelper.isProductPaid(IN_APP_PRODUCT)
    }
    
    
}
