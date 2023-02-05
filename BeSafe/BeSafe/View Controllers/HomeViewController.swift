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


    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func logOutButtonClicked(_ sender: Any) {
        print("logout clicked")
        try! Auth.auth().signOut()
        let viewController = storyboard?.instantiateViewController(withIdentifier: "EntryNavigationController") as? UINavigationController
        view.window?.rootViewController = viewController
        view.window?.makeKeyAndVisible()
    }
    @IBOutlet weak var logOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = FirebaseFirestore.Firestore.firestore()
        let docRef = db.collection("users").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data()["first_name"] ?? "blank")")
                    self.nameLabel.text = ("Welcome \(document.data()["first_name"] ?? "blank")")
                }
            }
    }

        
        
    }
    
}
