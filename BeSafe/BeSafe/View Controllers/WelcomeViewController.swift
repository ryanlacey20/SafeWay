//
//  HomeViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 12/11/2022.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func logOutButtonClicked(_ sender: Any) {
        print("logout clicked")
        try! Auth.auth().signOut()
        let viewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        view.window?.rootViewController = viewController
        view.window?.makeKeyAndVisible()
    }
    @IBOutlet weak var logOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = "Welcome " + "Ryan"
    }
    
}
