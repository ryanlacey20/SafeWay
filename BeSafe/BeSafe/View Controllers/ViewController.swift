//
//  SignUpViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 12/11/2022.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBAction func loginButton(_ sender: Any) {
    }
    @IBAction func signUpButton(_ sender: Any) {
    }
    
    func goToWelcomeScreen(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        self.show(nextViewController, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if Auth.auth().currentUser != nil {
          // User is signed in.
            print("USER IS LOGGED IN CUNT")
            self.goToWelcomeScreen()
        } else {
          // No user is signed in.
            print("THE USER IS LOGGED OUT !")
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
