//
//  LoginViewController.swift
//  Gigs
//
//  Created by Wesley Ryan on 4/7/20.
//  Copyright © 2020 Wesley Ryan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    enum LoginType {
        case signUp
        case login
    }
    
    @IBOutlet weak var segmentedControll: UISegmentedControl!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var apiController = APIController?
    var loginType = LoginType.signUp
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        // create a user by grabbing the text from the textField.
        guard let username = usernameTextField.text,
            let password = passwordTextField.text,
            //checking to make sure the textFields are not empty.
            !username.isEmpty,
            !password.isEmpty else { return }
        
        let user = User(username: username, password: password)
        //perform the login or signUp depending on the loginType
        if loginType == .signUp {
            signUp(with: user)
        } else {
            login(with: user)
        }
    }
    
    
    func signUp(with user: User) {
        apiController.signUp(with: user) { (error) in
            if let error = error {
                NSLog("Error during sign up: \(error)")
            } else {
                
                let alert = UIAlertController(title: "Sign Up Successful",
                                              message: "Please login.",
                                              preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                alert.addAction(okAction)
                self.present(alert, animated: true) {
                    //after alert change the following:::
                    self.loginType = .login
                    self.segmentedControll.selectedSegmentIndex = 1
                    self.loginButton.setTitle("Login", for: .normal)
                }
            }
        }
    }
    
    func login(with user: User) {
        apiController.login(with: user) { (error) in
            if let error = error {
                NSLog("Error occured during sign in: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func signInTypeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            loginType = .signUp
            loginButton.setTitle("Sign Up", for: .normal)
        } else {
            loginType = .login
            loginButton.setTitle("Login", for: .normal)
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

}
