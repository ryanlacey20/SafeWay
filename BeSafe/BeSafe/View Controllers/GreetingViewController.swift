//
//  GreetingViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 12/11/2022.
//

import UIKit
import FirebaseAuth

class GreetingViewController: UIViewController {

    @IBAction func loginButton(_ sender: Any) {
    }
    @IBAction func signUpButton(_ sender: Any) {
    }
    
    
    func goToWelcomeScreen(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: Constants.Storyboard.welcomePage) as! UITabBarController
        self.show(nextViewController, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let navController = self.navigationController {
            print("here is nav controllers1", navController.viewControllers)
        }
        // Do any additional setup after loading the view.
        if Auth.auth().currentUser != nil {
          // User is signed in.
            Utilities.getCurrentUserName { username in
                Constants.currentUser.username = username!
            }
            Constants.currentUser.uid = Auth.auth().currentUser!.uid
            self.goToWelcomeScreen()
            print("user is signed in")
        } else {
          // No user is signed in.
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
