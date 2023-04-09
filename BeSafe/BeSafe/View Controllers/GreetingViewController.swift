//
//  GreetingViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 12/11/2022.
//

import FirebaseAuth
import UIKit

class GreetingViewController: UIViewController {
    @IBAction func loginButton(_: Any) {}

    @IBAction func signUpButton(_: Any) {}

    func goToWelcomeScreen() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.welcomePage) as! UITabBarController
        show(nextViewController, sender: self)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if Auth.auth().currentUser != nil {
            // User is signed in.
            goToWelcomeScreen()
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
