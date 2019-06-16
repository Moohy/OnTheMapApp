//
//  loginVC.swift
//  On The Map
//
//  Created by Mohammed on 3/6/19.
//  Copyright © 2019 Mohammed. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    
    @IBAction func signin(_ sender: Any) {
        updateUI(processing: true)
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespaces), let password = passwordTextField.text?.trimmingCharacters(in: .whitespaces), !email.isEmpty, !password.isEmpty
            else {
                alert(title: "Warning", message: "Something went wrong!")
                updateUI(processing: false)
                return
        }
        UdacityAPI.postSession(with: email, password: password) {(result, error) in
            if let error = error {
                self.alert(title: "Error", message: error.localizedDescription)
                self.updateUI(processing: false)
                return
            }
            if let error = result?["error"] as? String {
                self.alert(title: "Error", message: error)
                self.updateUI(processing: false)
            }
            if let session = result?["session"] as? [String:Any], let sessionId = session["id"] as? String {
                UdacityAPI.delSession{ (error) in
                    if let error = error {
                        self.alert(title: "Error", message: error.localizedDescription)
                        self.updateUI(processing: false)
                        return
                    }
                    self.updateUI(processing: false)
                    DispatchQueue.main.async {
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        self.performSegue(withIdentifier: "showTapVC", sender: self)
                    }
                }
            }
            self.updateUI(processing: false)
        }
    }
    
    func updateUI(processing: Bool) {
        DispatchQueue.main.async{
            self.emailTextField.isUserInteractionEnabled = !processing
            self.passwordTextField.isUserInteractionEnabled = !processing
            self.signinButton.isUserInteractionEnabled = !processing
        }
    }
}



extension UIViewController{
    func alert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
