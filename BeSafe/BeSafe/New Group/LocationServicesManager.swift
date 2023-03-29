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

    func startSharingLocation(sharedWith: String) {
        let sharingUsername = Auth.auth().currentUser?.displayName
        let location = currentLocation

        let timestamp = NSDate().timeIntervalSince1970
        let expirationTime = timestamp + 3600 // share location for 1 hour

        Utilities.getSOSContacts(forUser: (Auth.auth().currentUser?.displayName)!){(sosContacts) in
            
            let userLocation = ["latitude": location?.coordinate.latitude,
                                "longitude": location?.coordinate.longitude,
                                "expirationTime": expirationTime,
                                "sharedAt" : timestamp,
                                "sharingUsername": Auth.auth().currentUser!.displayName,
                                "sharedWith": sosContacts
            ] as [String: Any]
            self.geoFire.setLocation(location!, forKey: sharingUsername!) { error in
                if let error = error {
                    print("Error setting location: \(error.localizedDescription)")
                } else {
                    self.db.collection("users").document((Auth.auth().currentUser?.displayName)!).updateData(["isSharingLocation": true])
                    self.databaseRef.child("user_locations").child(sharingUsername!).setValue(userLocation)
                    print("Location shared successfully")

                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
                        self.updateLocation(withUser: (Auth.auth().currentUser?.displayName)!, timestamp: expirationTime)
                    }
                }
            }
        }
        



    }

    func stopSharingLocation(withUser username: String) {
        geoFire.removeKey((Auth.auth().currentUser?.displayName)!)
        databaseRef.child("user_locations").child(username).removeValue()
        timer?.invalidate()
        db.collection("users").document((Auth.auth().currentUser?.displayName)!).updateData(["isSharingLocation": false])
    }

    func updateLocation(withUser username: String, timestamp: Double) {
        guard let location = currentLocation else { return }
        Utilities.getSOSContacts(forUser: username) { sosContacts in
            let userLocation = ["latitude": location.coordinate.latitude,
                                "longitude": location.coordinate.longitude,
                                "expirationTime": timestamp,
                                "sharingUsername": Auth.auth().currentUser?.displayName,
                                "sharedWith": sosContacts ] as [String: Any]

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
        db.collection("users").document((Auth.auth().currentUser?.displayName)!).getDocument { userData, _ in
            if let userData = userData {
                let data = userData.data()
                let isSharingFlag = data?["isSharingLocation"] as? Bool
                completion(isSharingFlag ?? false)
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
