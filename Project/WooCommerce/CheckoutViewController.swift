//
//  CheckoutViewController.swift
//  Universal
//
//  Created by Mark on 24/03/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation
import WebKit

final class CheckoutViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var completedView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        disableScroll()
        
        let callback = {(result: Bool) -> Void in
            if (result) {
                print("Cookies: ", CookieCart.cartCookies.cookies!)
                //Ensures that WebView has no existing products/session
                self.webView.configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
                let myURL = URL(string: AppDelegate.WOOCOMMERCE_HOST + checkout_url)
                var request = URLRequest(url: myURL!)
                request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: CookieCart.cartCookies.cookies ?? [])

                self.webView.load(request)
            } else {
                //TODO Error message
            }
        }
        
        CookieCart.init(completion: callback).getCookiesForCart();
    }
    
    func disableScroll(){
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);";
        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if (webView.url?.absoluteString.contains(checkout_order_received))! {
            completedView.isHidden = false
            Cart.sharedInstance.reset()
        }
    }
    
    @IBAction func completedButtonClick(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
}
