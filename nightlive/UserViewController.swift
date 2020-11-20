//
//  UserViewController.swift
//  back4app
//
//  Created by Hannes Schaletzky on 14.05.16.
//  Copyright © 2016 Hannes Schaletzky. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var anonymouslyButton: UIButton!
    
    var action = ""
    
    //MARK: - ViewController Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    //MARK: - User Interaction
    @IBAction func signupButtonPressed() {
        action = "Sign Up"
        segueToSignUpScreen()
    }
    
    @IBAction func loginButtonPressed() {
        action = "Login"
        segueToSignUpScreen()
    }
    
    @IBAction func continueWithOutUserPressed() {
        action = "Anonymously"
        segueToSignUpScreen()
    }
    
    //MARK: - Logic
    func segueToSignUpScreen() {
        performSegue(withIdentifier: "showSignUpLogin", sender: self)
    }
    
    func segueToUserPreferences() {
        performSegue(withIdentifier: "showUserPreferences", sender: self)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSignUpLogin" {
            let destinationVC = segue.destination as! SignUpLoginViewController
            destinationVC.action = action
        }
    }
    

}
