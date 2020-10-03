//
//  RegistrationViewController.swift
//  Universal
//
//  Created by suraj medar on 02/08/20.
//  Copyright © 2020 VRCODEHUB. All rights reserved.
//

import UIKit
import SafariServices
import WebKit

class RegistrationViewController: UIViewController {

    @IBOutlet weak var wkweb: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        title = "Create Your Account"
        
        
//        let viewMainC = SFSafariViewController(url: URL(string : "https://yourgastroapp.com/my-account")!)
//
//        present( viewMainC , animated: true)
        wkweb.load(URLRequest(url: URL(string:"https://yourgastroapp.com/my-account")!))
        
        
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
