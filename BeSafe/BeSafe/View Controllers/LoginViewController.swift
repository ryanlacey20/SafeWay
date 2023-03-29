//
//  LogInViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 12/11/2022.
//

import FirebaseAuth
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var emailTextField: UITextField!

    @IBOutlet var passwordTextField: UITextField!

    @IBOutlet var errorLabel: UILabel!

    @IBAction func loginTapped(_: Any) {
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if error != nil {
                self.errorLabel.text = error?.localizedDescription
                self.errorLabel.alpha = 1
            } else {
                // Move to the app homescreen
                self.backToHome()
            }
        }
    }

    func setUpElements() {
        errorLabel.alpha = 0
    }

    func backToHome() {
        let WelcomeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.welcomePage) as? UITabBarController
        view.window?.rootViewController = WelcomeViewController
        view.window?.makeKeyAndVisible()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
}
