//
//  HomeViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 12/11/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController {
    let db = FirebaseFirestore.Firestore.firestore()
    var emergencyUsernames: [String:Any] = [:]

    @IBOutlet weak var panicButton: UIButton!
    
    @IBAction func panicButtonTouchUpInside(_ sender: Any) {
        Utilities.getDataFromUser(user: Constants.currentUser.username) { data in
            self.emergencyUsernames = data["emergecyUsernames"] as! [String : Any]
        }
        print("panic activated")

    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func logOutButtonClicked(_ sender: Any) {
        try! Auth.auth().signOut()
        let viewController = storyboard?.instantiateViewController(withIdentifier: "EntryNavigationController") as? UINavigationController
        view.window?.rootViewController = viewController
        view.window?.makeKeyAndVisible()
    }
    @IBOutlet weak var logOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.getCurrentUserName { (name) in
            self.nameLabel.text = name
        }
    }
    
}
