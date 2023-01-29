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
    
    
    
    let searchController = UISearchController(searchResultsController: ResultsController())

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Friends"
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            print("went down the else route there was a problem")
            return
        }
//        let db = FirebaseFirestore.Firestore.firestore()
//        let docRef = db.collection("users").whereField("email", isEqualTo: Auth.auth().currentUser!.uid).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data()["first_name"] ?? "blank")")
//                    self.nameLabel.text = ("Welcome \(document.data()["first_name"] ?? "blank")")
//                }
//            }
//    }

      
//        let vc = searchController.searchResultsController as? ResultsController
//        vc?.view.backgroundColor = .yellow
        print(text)
    }

}
