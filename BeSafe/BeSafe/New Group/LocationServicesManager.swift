//
//  LocationServicesManager.swift
//  BeSafe
//
//  Created by Ryan Lacey on 23/02/2023.
//

import CoreLocation
import Firebase
import FirebaseFirestore
import GeoFire
import UIKit

class LocationServicesManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationServicesManager()
    private var locationManager = CLLocationManager()
    private var databaseRef: DatabaseReference!
    private var geoFire: GeoFire!
    private var timer: Timer?
    private var currentLocation: CLLocation?
    private var userLocationsRef: DatabaseReference!
    private var db: Firestore!
    private var timestamp = Double()

    override private init() {
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let databaseUrl = "https://besafe-fyp-default-rtdb.europe-west1.firebasedatabase.app"

        db = FirebaseFirestore.Firestore.firestore()
        databaseRef = Database.database(url: databaseUrl).reference()

        userLocationsRef = databaseRef.child("user_locations")
        geoFire = GeoFire(firebaseRef: databaseRef.child("user_locations"))
    }

    func startSharingLocation(sharedWith: String, status: String) {
        Utilities.getCurrentUserName { sharingUsername in
            let location = self.currentLocation

            self.timestamp = NSDate().timeIntervalSince1970
            let expirationTime = self.timestamp + 3600 // share location for 1 hour
            Utilities.getCurrentUserName { username in
                Utilities.getSOSContacts(forUser: (username)){(sosContacts) in
                    
                    let userLocation = ["latitude": location?.coordinate.latitude,
                                        "longitude": location?.coordinate.longitude,
                                        "expirationTime": expirationTime,
                                        "sharedAt" : self.timestamp,
                                        "sharingUsername": sharingUsername,
                                        "sharedWith": sosContacts,
                                        "status": status
                    ] as [String: Any]
                    self.geoFire.setLocation(location!, forKey: sharingUsername) { error in
                        if let error = error {
                            print("Error setting location: \(error.localizedDescription)")
                        } else {
                            self.db.collection("users").document((sharingUsername)).updateData(["isSharingLocation": true, "status": status])
                                                                 
                            self.databaseRef.child("user_locations").child(sharingUsername).setValue(userLocation)
                            print("Location shared successfully")

                            self.timer?.invalidate()
                            self.timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
                                self.updateLocation(withUser: (sharingUsername), expirationTimestamp: expirationTime, timestamp: self.timestamp, status: status)
                            }
                        }
                    }
                }
            }
        }

        



    }

    func stopSharingLocation(withUser username: String) {
        Utilities.getCurrentUserName { sharingUsername in

            self.databaseRef.child("user_locations").child(sharingUsername).removeValue()
            self.timer?.invalidate()
            self.db.collection("users").document(sharingUsername).updateData(["isSharingLocation": false])
        }
        
    }

    func updateLocation(withUser username: String, expirationTimestamp: Double, timestamp: Double, status: String) {
        guard let location = currentLocation else { return }
        Utilities.getSOSContacts(forUser: username) { sosContacts in
            let userLocation = ["latitude": location.coordinate.latitude,
                                "longitude": location.coordinate.longitude,
                                "expirationTime": expirationTimestamp,
                                "sharedAt": timestamp,
                                "sharingUsername": username,
                                "sharedWith": sosContacts,
                                "status": status] as [String: Any]
            

            self.geoFire.setLocation(location, forKey: username) { error in
                if let error = error {
                    print("Error updating location: \(error.localizedDescription)")
                } else {
                    self.databaseRef.child("user_locations").child(username).setValue(userLocation)
                    print("Location updated successfully")
                }
            }
        }
 
    }

    func isUserSharingLocation(forUser _: String, completion: @escaping (Bool) -> Void) {
        Utilities.getCurrentUserName { username in
            self.db.collection("users").document(username).getDocument { userData, _ in
                if let userData = userData {
                    let data = userData.data()
                    let isSharingFlag = data?["isSharingLocation"] as? Bool
                    completion(isSharingFlag ?? false)
                }
            }
        }

    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
        }
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
