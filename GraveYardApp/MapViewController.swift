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

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var signUp: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
 
    //==================================================
    // MARK: - Propeties
    //==================================================
    
    var currentAuthID = Auth.auth().currentUser?.uid
    var userId: String = ""
    var currentUser: User?
    var locationManager = CLLocationManager()

    //==================================================
    // MARK: - View Lifecycle
    //==================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForUserId()
        print(currentAuthID)
        setMapViewLocationAndUser()
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
    
    //==================================================
    // MARK: - Functions
    //==================================================
    
    func setMapViewLocationAndUser() {
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        }
        mapView.showsScale = true
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.userTrackingMode = .followWithHeading
        mapView.isUserInteractionEnabled = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        print("Location coordinates = \(locValue.latitude) \(locValue.longitude)")
        let userLocation = locations.last
        let viewRegion = MKCoordinateRegion(center: (userLocation?.coordinate)!, latitudinalMeters: 600, longitudinalMeters: 600)
        mapView.setRegion(viewRegion, animated: true)
    }
    
    func presentAlertController() {
        let newGraveAlert = UIAlertController(title: "New grave sight entry.", message: "Would you like to make a new entry at this location?", preferredStyle: .actionSheet)
        newGraveAlert.addAction(UIAlertAction(title: "Create new entry.", style: .default, handler: { action in
            print("Default Button Pressed")
            
            //TYLER'S prepareForSegue
            
        }))
        newGraveAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            print("Cancel Button Pressed")
            
            for annotation in self.mapView.annotations {
                if annotation.title == "New Entry" {
                    self.mapView.removeAnnotation(annotation)
                }
            }
            
        }))
        self.present(newGraveAlert, animated: true)
    }
    
    
    //==================================================
    // MARK: - Actions
    //==================================================
    
    
    @IBAction func userDidLongPress(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: self.mapView)
        let locationCoordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        annotation.title = "New Entry"
        self.mapView.addAnnotation(annotation)
        let annotationCoordinates = annotation.coordinate
        
        presentAlertController()
        
        
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
