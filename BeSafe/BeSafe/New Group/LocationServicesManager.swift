//
//  LocationServicesManager.swift
//  BeSafe
//
//  Created by Ryan Lacey on 23/02/2023.
//

import UIKit
import CoreLocation
import Firebase
import GeoFire
import FirebaseFirestore



class LocationServicesManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationServicesManager()
    private var locationManager = CLLocationManager()
    private var databaseRef: DatabaseReference!
    private var geoFire: GeoFire!
    private var timer: Timer?
    private var currentLocation: CLLocation?
    private var userLocationsRef: DatabaseReference!
    private var db: Firestore!

    
    private override init() {
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
    
    func startSharingLocation(withUser userId: String) {
        let sharingUsername = Constants.currentUser.username
        let location = currentLocation
        
        let timestamp = NSDate().timeIntervalSince1970
        let expirationTime = timestamp + 3600 // share location for 1 hour
        
        let userLocation = ["latitude": location?.coordinate.latitude,
                            "longitude": location?.coordinate.longitude,
                            "expirationTime": expirationTime,
                            "sharingUserId": Constants.currentUser.uid] as [String: Any]
        
        geoFire.setLocation(location!, forKey: userId) { (error) in
            if let error = error {
                print("Error setting location: \(error.localizedDescription)")
            } else {
                self.db.collection("users").document(Constants.currentUser.username).setData(["isSharinglocation" : true])
                self.databaseRef.child("user_locations").child(userId).setValue(userLocation)
                print("Location shared successfully")
                
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { (timer) in
                    self.updateLocation(withUser: userId, timestamp: expirationTime)
                }
            }
        }
    }
    
    func stopSharingLocation(withUser userId: String) {
        geoFire.removeKey(userId)
        databaseRef.child("user_locations").child(userId).removeValue()
        timer?.invalidate()
        self.db.collection("users").document(Constants.currentUser.username).setData(["isSharinglocation" : false])
    }
    
    func updateLocation(withUser userId: String, timestamp: Double) {
        guard let location = currentLocation else { return }
        
        let userLocation = ["latitude": location.coordinate.latitude,
                            "longitude": location.coordinate.longitude,
                            "expirationTime": timestamp,
                            "sharingUserId": Auth.auth().currentUser?.uid ?? ""] as [String: Any]
        
        geoFire.setLocation(location, forKey: userId) { (error) in
            if let error = error {
                print("Error updating location: \(error.localizedDescription)")
            } else {
                self.databaseRef.child("user_locations").child(userId).setValue(userLocation)
                print("Location updated successfully")
            }
        }
    }

    func isUserSharingLocation(forUser: String, completion: @escaping (Bool) -> Void){
        db.collection("users").document(Constants.currentUser.username).getDocument { (userData, Error) in
            if let userData = userData{
                let data = userData.data()
                let isSharingFlag = data?["isSharinglocation"] as? Bool
                completion(isSharingFlag ?? false)
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
