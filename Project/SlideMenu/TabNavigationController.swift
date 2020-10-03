//
//  TabNavigationController.swift
//  Universal
//
//  Created by Mark on 19/09/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation
//import AMScrollingNavbar

class TabNavigationController : UINavigationController {
    private var prevShadowColor: UIColor?
    
    private var statusBarBackgroundView: UIView?
    
    //TODO When swiping back from a detailView (i.e. a wordpress post) to the main view (with big titl) but then cancelling the swipe action, the navigationbar is misformed.
    
    @IBOutlet private var gradientView: NavbarGradientView!{
        didSet{
            //Doing this here prevents the view from being null
            self.view.insertSubview(gradientView, belowSubview:self.navigationBar)
            (self.navigationBar as! CustomNavigationBar).backgroundView = gradientView
        }
    }
    var item: [AnyHashable] = []
    var hiddenTabBar = false
    var menuButton: UIButton?
    
    let NAVBAR_TRANSITION_BGCOLOR = UIColor.white
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.prevShadowColor = self.revealViewController()?.frontViewShadowColor
        
        self.configureNavbar()
    }
    
    func configureNavbar() {
        
        /**
         //GRADIENT
         if (gradient) {
         CAGradientLayer *gradient = [CAGradientLayer layer];
         gradient.frame = self.gradientView.plainView.bounds;
         UIColor *color1 = [UIColor colorWithRed:71.0f/255.0f  green:191.0f/255.0f  blue:251.0f/255.0f  alpha:1.0];
         UIColor *color2 = [UIColor colorWithRed:69.0f/255.0f  green:148.0f/255.0f  blue:251.0f/255.0f  alpha:1.0];
         gradient.colors = [NSArray arrayWithObjects:(id)[color1 CGColor], (id)[color2 CGColor], nil];
         [_gradientView.plainView.layer insertSublayer:gradient atIndex:0];
         }**/
        
        /**
         //SOLID
         _gradientView.plainView.backgroundColor = APP_THEME_COLOR;
         **/
        
        // set appearance of status and nav bars
        self.forceDarkNavigation(force: false)
        self.navigationBar.isTranslucent = true
        self.navigationBar.backgroundColor = UIColor.clear
        self.navigationBar.prefersLargeTitles = false
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        updateNavigationBarVisibilityIfNeeded(hidden: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // gradient view to cover both status bar (if present) and nav bar
        //CGRect barFrame = self.navigationBar.frame;
        //_gradientView.frame = CGRectMake(0, 0, barFrame.size.width, barFrame.origin.y + barFrame.size.height);
    }
    
    override func pushViewController(_ viewController:UIViewController, animated:Bool) {
        super.pushViewController(viewController, animated:animated)
        
        (UIApplication.shared.delegate as! AppDelegate).showInterstitial(controller: self)

        updateNavigationBarVisibilityIfNeeded(hidden: false)
    }
    
    func configureViewController(viewController:UIViewController){
        if let config = Config.config as [Section]? {
            let hasOneItem = config.count == 1 && config[0].items.count == 1
            
            // add reveal button to the first nav item on the stack
            if self.viewControllers.count == 1 && !hasOneItem {
                let leftBarButton:UIBarButtonItem! = UIBarButtonItem(image:UIImage(named: "menu"),  style:UIBarButtonItem.Style.plain, target:self, action:#selector(menuClicked))
                viewController.navigationItem.leftBarButtonItem = leftBarButton
            }
            
            if self.viewControllers.count > 1 {
                self.revealViewController().frontViewShadowColor = NAVBAR_TRANSITION_BGCOLOR
            }
            
        }
    }
        
    @objc func menuClicked() {
        self.revealViewController().revealToggle(animated: true)
    }
    
    override func popViewController(animated:Bool) -> UIViewController? {
        let poppedVC:UIViewController! = super.popViewController(animated: animated)
        
        (UIApplication.shared.delegate as! AppDelegate).showInterstitial(controller: self)
        
        // switch off navbar transparency
        if self.viewControllers.count <= 1 {
            self.getGradientView().turnTransparency(on: false, animated:true, tabController: self.navigationController)
            self.revealViewController().frontViewShadowColor = prevShadowColor
        }
        
        updateNavigationBarVisibilityIfNeeded(hidden: true)
        
        return poppedVC
    }
    
    func updateNavigationBarVisibilityIfNeeded(hidden: Bool){

        if (AppDelegate.DISABLED_NAVIGATIONBAR) {
            self.setNavigationBarHidden(hidden, animated: false)
            gradientView.isHidden = hidden
            if (hidden) {
                if (statusBarBackgroundView == nil) {
                    statusBarBackgroundView = UIView(frame: UIApplication.shared.statusBarFrame)
                    let statusBarColor = UIColor.white
                    statusBarBackgroundView!.backgroundColor = statusBarColor
                    statusBarBackgroundView!.translatesAutoresizingMaskIntoConstraints = false
                    statusBarBackgroundView!.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]

                    view.addSubview(statusBarBackgroundView!)
                }
            } else if let statusBarView = statusBarBackgroundView {
                statusBarView.removeFromSuperview()
                statusBarBackgroundView = nil
            }
        }
    }
    
    /**
     * Update the statusbar appearance to use the light theme or default theme as defined in AppDelegate
     * Boolean 'force' can be used to override the theme set for a dark theme (i.e. for detailview fade header).
     */
    @objc func forceDarkNavigation(force: Bool) {
        if !AppDelegate.APP_THEME_LIGHT || force {
            //if (self.navigationBar.barStyle == UIBarStyleBlack) return;
            
            self.navigationBar.barStyle = UIBarStyle.black
            self.navigationBar.tintColor = UIColor.white
            //UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
            setStatusBar(style: .lightContent)
            
            let attributes: [NSAttributedString.Key: AnyObject] = [
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]
            
            UINavigationBar.appearance().titleTextAttributes = attributes
        } else {
            //if (self.navigationBar.barStyle == UIBarStyleDefault) return;
            
            self.navigationBar.barStyle = UIBarStyle.default
            self.navigationBar.tintColor = UIColor.black
            //UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
            setStatusBar(style: .default)
            
            let attributes: [NSAttributedString.Key: AnyObject] = [
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            
            UINavigationBar.appearance().titleTextAttributes = attributes
            
        }
    }
    
    //---- Utility methods for managing statusbar style
    
    private var statusBarStyle:UIStatusBarStyle! = .default
    private var prefersHiddenStatusbar = false;
    
    func setStatusBar(style: UIStatusBarStyle!){
        statusBarStyle = style
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return statusBarStyle
    }
    
    func setStatusBar(hidden: Bool){
        prefersHiddenStatusbar = hidden
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden: Bool {
      return prefersHiddenStatusbar
    }
    
    //---- Utility methods for managing navigationbar transparency
    
    /**
      * IBOutlet to gradientView is for some reason lost. This method is used instead to obtain the gradientView.
      **/
     @objc func getGradientView() -> NavbarGradientView {
         return (self.navigationBar as! CustomNavigationBar).backgroundView as! NavbarGradientView
     }
    
     @objc func turnTransparency(on: Bool, animated: Bool){
         self.getGradientView().turnTransparency(on: on, animated: animated, tabController: self)
     }
}
