//
//  HomeViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 12/11/2022.
//

import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import Foundation
import UIKit

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = LocationServicesManager.shared

    let db = FirebaseFirestore.Firestore.firestore()
    var sosContacts: [String] = []
    var isSharingLocation = Bool()
    var username: String?

    @IBOutlet var panicButton: UIButton!
    @IBOutlet weak var panicButtonErrorLabel: UILabel!
    
    @IBAction func panicButtonTouchUpInside(_: Any) {
        Utilities.getCurrentUserName(){ username in
            Utilities.getSOSContacts(forUser: username) { data in
                self.sosContacts = data
                if self.sosContacts == [] {
                    self.panicButtonErrorLabel.isHidden = false
                    self.panicButtonErrorLabel.text = "No SOS Contacts"
                }else{
                    self.panicButtonErrorLabel.isHidden = true
                    for user in self.sosContacts {
                        if self.isSharingLocation == false {
                            self.locationManager.startSharingLocation(sharedWith: user)
                        } else if self.isSharingLocation == true {
                            
                            self.locationManager.stopSharingLocation(withUser: user)
                        }
                    }
                }
                print("panic activated")
            }
        }
    }

    @IBOutlet var nameLabel: UILabel!

    @IBAction func logOutButtonClicked(_: Any) {
        try! Auth.auth().signOut()
        let viewController = storyboard?.instantiateViewController(withIdentifier: "EntryNavigationController") as? UINavigationController
        view.window?.rootViewController = viewController
        view.window?.makeKeyAndVisible()
    }

    @IBOutlet var logOutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.panicButtonErrorLabel.isHidden = true
        Utilities.getCurrentUserName { username in
            self.username = username
            self.nameLabel.text = username
            self.db.collection("users").document(username).addSnapshotListener { snapshot, error in
                if error != nil {
                    print("error setting up watcher for the user sharing location flag")
                }
                let data = snapshot!.data()
                let locationSharingFlag = data!["isSharingLocation"] as? Bool ?? false
                if locationSharingFlag == true {
                    self.panicButton.setTitle("Location has been shared", for: .normal)
                    self.panicButton.backgroundColor = .red
                    self.panicButton.layer.cornerRadius = 10
                } else {
                    self.panicButton.setTitle("Panic button \nPress to alert sos contacts", for: .normal)
                    self.panicButton.backgroundColor = .systemGray6
                    self.panicButton.layer.cornerRadius = 10
                }
                self.isSharingLocation = locationSharingFlag
            }
        }

    }
}
