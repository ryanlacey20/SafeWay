//
//  AddFriendsViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 19/01/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ResultsController: UIViewController {
    override func viewDidLoad() {
    }
}

class AddFriendsViewController : UIViewController, UISearchResultsUpdating {
    
    let db = FirebaseFirestore.Firestore.firestore()
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var followUserbutton: UIButton!
    
    @IBAction func onFollowPress(_ sender: Any) {
        print("pressed here")
    }
    
    
    let searchController = UISearchController(searchResultsController: ResultsController())
    
    var nameText = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.obscuresBackgroundDuringPresentation = false
        title = "Friends"
        usernameLabel.text = ""
        nameLabel.text = ""
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
    }
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            print("went down the else route there was a problem")
            return
        }
        
        db.collection("users").whereField("username", isEqualTo: text)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    if let document = querySnapshot?.documents.first {
                        let fname = document.get("first_name") as! String
                        let lname = document.get("last_name") as! String
                        let username = document.get("username") as! String
                        print("Field 'fname' value is: \(fname)")
                        self.nameLabel.text = "\(fname) \(lname)"
                        self.usernameLabel.text = "\(username)"
                        self.followUserbutton.setTitle("follow user", for: .normal)
                        self.nameText = text
                        searchController.isActive = false
                        
                    } else {
                        print("Document with uname 'uname' not found.")
                        self.nameLabel.text = ""
                        self.usernameLabel.text = ""
                    }
                }
        }

//        let vc = searchController.searchResultsController as? ResultsController
//        vc?.view.backgroundColor = .yellow
        print(text)
    }
}
