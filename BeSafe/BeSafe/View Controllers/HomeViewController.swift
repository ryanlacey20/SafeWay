//
//  HomeViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 12/11/2022.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import CoreLocation


class HomeViewController: UIViewController, CLLocationManagerDelegate  {
    
    let locationManager = LocationServicesManager.shared

    let db = FirebaseFirestore.Firestore.firestore()
    var sosContacts: [String] = []


    @IBOutlet weak var panicButton: UIButton!
    
    @IBAction func panicButtonTouchUpInside(_ sender: Any) {
        Utilities.getSOSContacts(forUser: Constants.currentUser.username) { data in
            self.sosContacts = data
//            for user in sosContacts{
//                
//            }
        }
        print("panic activated")
        locationManager.startSharingLocation(withUser: "8b4zQ7Q3fPSPTCbCUp8U1GNUaPD2")
        locationManager.isUserSharingLocation(forUser: Constants.currentUser.username) {(isUserSharingLocation) in
            print(isUserSharingLocation,"<--- what this said")
        }

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
        
        self.nameLabel.text = Constants.currentUser.username
        
    }
    
}
