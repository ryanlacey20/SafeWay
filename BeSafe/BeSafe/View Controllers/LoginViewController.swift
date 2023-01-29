//
//  LogInViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 12/11/2022.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

   
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func loginTapped(_ sender: Any) {
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil{
                self.errorLabel.text = error?.localizedDescription
                self.errorLabel.alpha = 1
            }else{
                //Move to the app homescreen
                self.backToHome()
            }
        }
    }
    
    func setUpElements(){
        errorLabel.alpha = 0;
    }
    func backToHome(){
        let WelcomeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.welcomePage) as? UITabBarController
        view.window?.rootViewController = WelcomeViewController
        view.window?.makeKeyAndVisible()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }

}
