//
//  panicMessageMapViewController.swift
//  BeSafe
//
//  Created by Ryan Lacey on 27/03/2023.
//

import UIKit
import MapKit

class PanicMessageMapViewController: UIViewController, MKMapViewDelegate {
    var username = String()
    var latitude = 0.0
    var longitude = 0.0
    var regionRadius = 1000
    var timeSent = String()
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var sentAtTimeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = self.username
        self.sentAtTimeLabel.text = "sent at: \(timeSent)"
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location

        mapView.addAnnotation(annotation)
        
        var center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let region = MKCoordinateRegion(center: center, latitudinalMeters: CLLocationDistance(regionRadius), longitudinalMeters: CLLocationDistance(regionRadius))
        mapView.setRegion(region, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
