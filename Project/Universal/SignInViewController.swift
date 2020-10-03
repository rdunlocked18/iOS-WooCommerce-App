//
//  SignInViewController.swift
//  Universal
//
//  Created by suraj medar on 03/08/20.
//  Copyright © 2020 VRCODEHUB. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Login To YourGastro Account"
    }
    
    @IBAction func signInBtnAction(_ sender: Any) {
        if emailTextField.text == "" {
            let alert = UIAlertController(title: "", message: "Please enter email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            }))
            
            present(alert, animated: true)
        } else if emailTextField.text!.isValidEmail == false {
            let alert = UIAlertController(title: "", message: "Please enter valid email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            }))
            
            present(alert, animated: true)
        } else if passwordTextField.text == "" {
            let alert = UIAlertController(title: "", message: "Please enter password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            }))
            present(alert, animated: true)
        } else {
            self.getLogin(userEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "")
        }
    }
    
    @IBAction func registerBtnAction(_ sender: Any) {
    }
    
}

extension SignInViewController {
    func getLogin(userEmail: String, password: String)  {
        let semaphore = DispatchSemaphore (value: 0)
        let number = Int.random(in: 0 ... 10)
        var request = URLRequest(url: URL(string: "https://yourgastroapp.com/api/auth/generate_auth_cookie/?nonce=\(number)&username=\(userEmail)&password=\(password)")!,timeoutInterval: Double.infinity)
        request.addValue("Basic Og==", forHTTPHeaderField: "Authorization")
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.addValue("wordpress_test_cookie=WP+Cookie+check", forHTTPHeaderField: "Cookie")
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let urlContent = data {
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    if let status = (jsonResult as! NSDictionary)["status"] as? String {
                        if "ok" == status {
                            self.getUserData(result : jsonResult as! NSDictionary)
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "showLoginToHomePageSegue", sender: nil)
                            }
                        } else {
                            OperationQueue.main.addOperation
                                {
                                    self.alertMessage(title: "", message: "status")
                            }
                        }
                    }
                } catch {
                    OperationQueue.main.addOperation
                        {
                            self.alertMessage(title: "", message: "Network error!")
                    }
                }
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
    
    func getUserData(result : NSDictionary) {
        guard let user = result["user"] as? AnyObject else { return }
        guard let userID = user["id"] else { return  }
        UserDefaults.standard.set(userID, forKey: "userId")
        UserDefaults.standard.set(true, forKey: "isLogin")
    }
}
