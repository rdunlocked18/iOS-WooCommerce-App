//
//  LoginViewController.swift
//  Universal
//
//  Created by suraj medar on 26/07/20.
//  Copyright © 2020 VRCODEHUB. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var numberTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func iBBtnAction(_ sender: Any) {
        if numberTextField.text == "1101" {
            performSegue(withIdentifier: "showloginbToNavigationViewSegue", sender: nil)
        } else {
            let alert = UIAlertController(title: "Invalid ZIP", message: "Sorry The Restaurant Does Not Deliver To Your Area !", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            }))
            
            present(alert, animated: true)
        }
    }
    
}
