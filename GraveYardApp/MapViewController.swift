//
//  MapViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/17/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class MapViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var signUp: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var currentAuthID = Auth.auth().currentUser?.uid
    var userId: String = ""
    var currentUser: User?
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        checkForUserId()
        print(currentAuthID)
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkForUserId()
    }
    
    func checkForUserId() {
        if currentAuthID == nil {
            signUp.title = "Sign Up"
        } else {
            signUp.title = "Log Out"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        print("Location coordinates = \(locValue.latitude) \(locValue.longitude)")
        let userLocation = locations.last
        let viewRegion = MKCoordinateRegion(center: (userLocation?.coordinate)!, latitudinalMeters: 600, longitudinalMeters: 600)
        mapView.setRegion(viewRegion, animated: true)
    }
    
    @IBAction func SignInTapped(_ sender: UIBarButtonItem) {
        if currentAuthID == nil {
            performSegue(withIdentifier: "segueToSignUp", sender: self)
        } else {
            let locationAlert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            locationAlert.addAction(cancelAction)
            
            let goToSettingsAction = UIAlertAction(title: "Log Out", style: .default, handler: { _ in      self.currentUser = nil
                self.userId = ""
                try! Auth.auth().signOut()
                self.currentAuthID = nil
                self.checkForUserId()
            })
                locationAlert.addAction(goToSettingsAction)
            present(locationAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func unwindToMap(_ sender: UIStoryboardSegue) {}

}
