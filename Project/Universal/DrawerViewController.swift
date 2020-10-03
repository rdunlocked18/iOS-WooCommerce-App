//
//  DrawerViewController.swift
//  Universal
//
//  Created by suraj medar on 01/08/20.
//  Copyright © 2020 VRCODEHUB. All rights reserved.
//

import UIKit
import SideMenu

class DrawerViewController: UIViewController {
    
    @IBOutlet weak var loginBtnStackView: UIStackView!
    @IBOutlet weak var orderBtn: UIButton!
    @IBOutlet weak var langSw: UISwitch!
    @IBOutlet weak var currentLangText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.bool(forKey: "isLogin") == true {
            orderBtn.isHidden = false
            //loginBtnStackView.alpha = 0
        } else{
            orderBtn.isHidden = true
            //loginBtnStackView.alpha = 0
        }
    }
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func switchLanguage(_ sender: UISwitch) {
        if langSw.isOn {
            currentLangText.text = "Current language : DE"
        }else {
            currentLangText.text = "Current language : EN"
        }
                
    }
    
    
    @IBAction func loginBtnAction(_ sender: Any) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func registerBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "showWebViewSegue", sender: nil)
    }
    
    @IBAction func homoBtnAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cartBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "showCartViewSegue", sender: nil)
    }
    
    @IBAction func orderBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "showDrawerToOrderListViewSegue", sender: nil)
    }
    
    @IBAction func navigationBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "showNavigationSegue", sender: nil)
    }
    
    @IBAction func callBtnAction(_ sender: Any) {
        if let phoneCallURL = URL(string: "tel://9999999999") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    application.openURL(phoneCallURL as URL)
                    
                }
            }
        }
    }
    
    @IBAction func openingHourBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "showOpeningHoursViewSegue", sender: nil)
    }
    
    @IBAction func shareBtnAction(_ sender: Any) {
        
        //Set the default sharing message.
               let message = "Hi ! have A look At This amazing app !"
               //Set the link to share.
               if let link = NSURL(string: "http://yoururl.com")
               {
                let objectsToShare = [message,link] as [Any]
                   let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                   //activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
                activityVC.isModalInPopover = true
                self.present(activityVC, animated: true, completion: nil)
               }
        
        
        //performSegue(withIdentifier: "showShareViewSegue", sender: nil)
    }
    
    @IBAction func feedbackBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "showFeedbackViewSegue", sender: nil)
    }
    
    @IBAction func impressumBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "showImpressumViewSegue", sender: nil)
    }
    
    @IBAction func allergenBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "showAllergenViewSegue", sender: nil)
    }
    
}
