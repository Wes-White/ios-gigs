//
//  LoginViewController.swift
//  Gigs
//
//  Created by Wesley Ryan on 4/7/20.
//  Copyright © 2020 Wesley Ryan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var segmentedControll: UISegmentedControl!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButton(_ sender: Any) {
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
