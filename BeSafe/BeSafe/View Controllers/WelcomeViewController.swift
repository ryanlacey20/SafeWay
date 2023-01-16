//
//  HomeViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 12/11/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

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
        let db = FirebaseFirestore.Firestore.firestore()
        let docRef = db.collection("users").document(Auth.auth().currentUser!.uid)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                let fName = (document.data()!["first_name"])
                if let fName = fName{
                    self.nameLabel.text = "Welcome \(fName)"
                }
            } else {
                print("Document does not exist")
            }
        }

        
        
    }
    
}
