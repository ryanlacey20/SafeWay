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
    var panicMessageLength = 0
    let db = FirebaseFirestore.Firestore.firestore()
    var sosContacts: [String] = []
    var isSharingLocation = Bool()
    var username: String?

    @IBOutlet weak var confirmationLabel: UILabel!
    @IBOutlet var panicButton: UIButton!
    @IBOutlet weak var panicButtonErrorLabel: UILabel!
    
    @IBAction func markHomeSafe(_ sender: Any) {
        confirmationLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.confirmationLabel.isHidden = true
        }
        Utilities.getCurrentUserName { username in

            self.db.collection("users").document(username).updateData(["markedHomeAt" : Timestamp()])
        }
        
    }
    
    @IBOutlet weak var amberPanicButtonErrorLabel: UILabel!
    
    func panicButtonPressed(status:String){
        logOutButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            self.logOutButton.isEnabled = true
        }
        Utilities.getCurrentUserName(){ username in
            Utilities.getSOSContacts(forUser: username) { data in
                self.sosContacts = data
                if self.sosContacts == [] {
                    if status == "red"{
                        self.panicButtonErrorLabel.isHidden = false
                        self.panicButtonErrorLabel.text = "No SOS Contacts"
                    } else{
                        self.amberPanicButtonErrorLabel.isHidden = false
                        self.amberPanicButtonErrorLabel.text = "No SOS Contacts"
                    }
                }else{
                    if status == "red"{
                        self.panicButtonErrorLabel.isHidden = true
                    }else{
                        self.amberPanicButtonErrorLabel.isHidden = true
                    }
                    for user in self.sosContacts {
                        if self.isSharingLocation == false {
                            self.locationManager.startSharingLocation(sharedWith: user, status: status)
                        } else if self.isSharingLocation == true {
                            self.db.collection("users").document(username).getDocument { docSnapshot, Error in
                                let data = docSnapshot?.data()
                                let currentStatus = data!["status"]
                                if currentStatus as! String == status {
                                    self.locationManager.stopSharingLocation()
                                } else {
                                    self.locationManager.startSharingLocation(sharedWith: user, status: status)
                                    
                                }
                            }
                            
                        }
                    }
                }
                print("panic activated")
            }
        }
    }
    @IBOutlet weak var markHomeSafe: UIButton!
    @IBAction func panicButtonTouchUpInside(_: Any) {
        panicButtonPressed(status: "red")
    }

    @IBOutlet weak var amberPanicButtonOutlet: UIButton!
    @IBAction func amberPanicButton(_ sender: Any) {
        panicButtonPressed(status: "amber")
    }
    @IBOutlet var nameLabel: UILabel!

    @IBAction func logOutButtonClicked(_: Any) {
        try! Auth.auth().signOut()
        let viewController = storyboard?.instantiateViewController(withIdentifier: "EntryNavigationController") as? UINavigationController
        view.window?.rootViewController = viewController
        view.window?.makeKeyAndVisible()
    }

    @IBOutlet var logOutButton: UIButton!

    @IBOutlet weak var panicMessagesLabel: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.confirmationLabel.isHidden = true
        self.panicButtonErrorLabel.isHidden = true
        self.amberPanicButtonErrorLabel.isHidden = true
        Utilities.getCurrentUserName { username in
            Utilities.getPanicMessages(username: username) { panicMessages in
                if self.panicMessageLength < panicMessages.count{
                    self.sendPanicMessageNotification()
                }
                self.panicMessageLength = panicMessages.count
                if !panicMessages.isEmpty {
                    self.panicMessagesLabel.setImage(UIImage(systemName: "circlebadge.fill")?.withTintColor(UIColor.red), for: .normal)
                    

                } else{                     self.panicMessagesLabel.setImage(UIImage(systemName: "circlebadge")?.withTintColor(UIColor.red), for: .normal)}
            }
            self.username = username
            self.nameLabel.text = username
            self.db.collection("users").document(username).addSnapshotListener { snapshot, error in
                if error != nil {
                    print("error setting up watcher for the user sharing location flag")
                }
                let data = snapshot!.data()
                let locationSharingFlag = data!["isSharingLocation"] as? Bool ?? false
                
                if locationSharingFlag == true {
                    let status = data!["status"] as? String
                    if status == "red" {
                        self.panicButton.setTitle("Location has been shared", for: .normal)
                        self.panicButton.backgroundColor = .red
                        self.panicButton.layer.cornerRadius = 10
                        
                        //reset amber buton
                        self.amberPanicButtonOutlet.setTitle("Amber Panic button", for: .normal)
                        let red2 = CGFloat(255) / 255.0
                        let green2 = CGFloat(255) / 255.0
                        let blue2 = CGFloat(204) / 255.0
                        let color2 = UIColor(red: red2, green: green2, blue: blue2, alpha: 1.0)
                        self.amberPanicButtonOutlet.backgroundColor = color2
                        self.amberPanicButtonOutlet.layer.cornerRadius = 10
                    } else{
                        self.amberPanicButtonOutlet.setTitle("Location has been shared", for: .normal)
                        self.amberPanicButtonOutlet.backgroundColor = .orange
                        self.amberPanicButtonOutlet.layer.cornerRadius = 10
                        
                        // reset red button
                        //red
                        self.panicButton.setTitle("Red Panic Button", for: .normal)
                        let red1 = CGFloat(252) / 255.0
                        let green1 = CGFloat(200) / 255.0
                        let blue1 = CGFloat(200) / 255.0
                        let color1 = UIColor(red: red1, green: green1, blue: blue1, alpha: 1.0)
                        self.panicButton.backgroundColor = color1
                        self.panicButton.layer.cornerRadius = 10
                    }
                } else {
                    //red
                    self.panicButton.setTitle("Red Panic Button", for: .normal)
                    let red1 = CGFloat(252) / 255.0
                    let green1 = CGFloat(200) / 255.0
                    let blue1 = CGFloat(200) / 255.0
                    let color1 = UIColor(red: red1, green: green1, blue: blue1, alpha: 1.0)
                    self.panicButton.backgroundColor = color1
                    self.panicButton.layer.cornerRadius = 10
                    
                    //amber
                    self.amberPanicButtonOutlet.setTitle("Amber Panic Button", for: .normal)
                    let red2 = CGFloat(255) / 255.0
                    let green2 = CGFloat(255) / 255.0
                    let blue2 = CGFloat(204) / 255.0
                    let color2 = UIColor(red: red2, green: green2, blue: blue2, alpha: 1.0)
                    self.amberPanicButtonOutlet.backgroundColor = color2
                    self.amberPanicButtonOutlet.layer.cornerRadius = 10
                }
                self.isSharingLocation = locationSharingFlag
            }
        }

    }
    
    func sendPanicMessageNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🚨Panic Message Recieved🚨"
        content.body = "A user has shared a panic message"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "localNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

}
