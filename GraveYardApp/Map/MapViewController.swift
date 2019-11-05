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
    
    static let shared = MapViewController()
    var currentAuthID = Auth.auth().currentUser?.uid
    var userId: String = ""
    var currentUser: User?
    var locationManager = CLLocationManager()
    var db = Firestore.firestore()
    var currentGraveId: String?
    var currentGraveLocationLatitude: String?
    var currentGraveLocationLongitude: String?
    
    //==================================================
    // MARK: - View Lifecycle
    //==================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForUserId()
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
    
    //    func createData() {
    //
    //        // IDEA, image of a folder, image that tells them what it is. is is a text doc is it pics? is ait a video? is it multiple? when u make a story ONE VC.
    //        // when the id are made, a check to search for ids of the same must be made. if they are the same, rinse and repeat.
    //        if currentAuthID == nil {
    //            let notSignInAlert = UIAlertController(title: "You are not signed in", message: "You must sign in to create a grave location", preferredStyle: .alert)
    //            let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
    //            notSignInAlert.addAction(dismiss)
    //            self.present(notSignInAlert, animated: true, completion: nil)
    //        } else {
    //        let id = currentAuthID!
    //        let graveId = UUID().uuidString
    //        let newGraveId = UUID().uuidString
    //        let name: String = ""
    //        let birthDate: String = ""
    //        let birthLocation: String = ""
    //        let deathDate: String = ""
    //        let deathLocation: String = ""
    //        let marriageStatus: String = ""
    //        let bio: String = ""
    //
    //        var grave = Grave(creatorId: id,
    //                          graveId: graveId,
    //                          name: name,
    //                          birthDate: birthDate,
    //                          birthLocation: birthLocation,
    //                          deathDate: deathDate,
    //                          deathLocation: deathLocation,
    //                          marriageStatus: marriageStatus,
    //                          bio: bio)
    //
    //        let graveRef = self.db.collection("grave")
    //        graveRef.whereField("graveId", isEqualTo: grave.graveId).getDocuments { (snapshot, error) in
    //            if error != nil {
    //                print(Error.self)
    //            } else {
    //                if snapshot?.description == grave.graveId {
    //                    grave.graveId = newGraveId
    //                } else {
    //                    print("no dupli")
    //                }
    //            }
    //        }
    //        graveRef.document(String(grave.graveId)).setData(grave.dictionary) { err in
    //            if let err = err {
    //                let graveCreationFailAert = UIAlertController(title: "Failed to create a Grave", message: "Your device failed to properly create a Grave on your desired destination, Please check your wifi and try again", preferredStyle: .alert)
    //                let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
    //                graveCreationFailAert.addAction(dismiss)
    //                self.present(graveCreationFailAert, animated: true, completion: nil)
    //                print(err)
    //            } else {
    //                self.performSegue(withIdentifier: "segueToGrave", sender: nil)
    //                print("Added Data")
    //            }
    //        }
    //        }
    //    }
    
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
    
    //    func presentAlertController() {
    //        let newGraveAlert = UIAlertController(title: "New grave sight entry.", message: "Would you like to make a new entry at this location?", preferredStyle: .actionSheet)
    //        newGraveAlert.addAction(UIAlertAction(title: "Create new entry.", style: .default, handler: { action in
    //            print("Default Button Pressed")
    //
    //            //TYLER'S prepareForSegue
    //            self.createData()
    //
    //        }))
    //        newGraveAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
    //            print("Cancel Button Pressed")
    //
    //            for annotation in self.mapView.annotations {
    //                if annotation.title == "New Entry" {
    //                    self.mapView.removeAnnotation(annotation)
    //                }
    //            }
    //
    //        }))
    //        self.present(newGraveAlert, animated: true)
    //    }
    
    
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
        
        let newGraveAlert = UIAlertController(title: "New grave sight entry.", message: "Would you like to make a new entry at this location?", preferredStyle: .actionSheet)
        newGraveAlert.addAction(UIAlertAction(title: "Create new entry", style: .default, handler: { action in
            print("Default Button Pressed")
            
            //TYLER'S prepareForSegue minus the prepare for and instead just a ton of code.
            if self.currentAuthID == nil {
                let notSignInAlert = UIAlertController(title: "You are not signed in", message: "You must sign in to create a grave location", preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
                notSignInAlert.addAction(dismiss)
                self.present(notSignInAlert, animated: true, completion: nil)
            } else {
                let id = self.currentAuthID!
                MapViewController.shared.currentGraveId = UUID().uuidString
                self.currentGraveLocationLatitude = String(annotationCoordinates.latitude)
                self.currentGraveLocationLongitude = String(annotationCoordinates.longitude)
                let newGraveId = UUID().uuidString
                let name: String = "jimmAy"
                let birthDate: String = ""
                let birthLocation: String = ""
                let deathDate: String = ""
                let deathLocation: String = ""
                let marriageStatus: String = ""
                let bio: String = ""
                guard let graveId: String = MapViewController.shared.currentGraveId else { return }
                guard let graveLocationLatitude: String = MapViewController.shared.currentGraveLocationLatitude else { return }
                guard let graveLocationLongitude: String = MapViewController.shared.currentGraveLocationLongitude else { return }

                
                var grave = Grave(creatorId: id,
                                  graveId: graveId,
                                  name: name,
                                  birthDate: birthDate,
                                  birthLocation: birthLocation,
                                  deathDate: deathDate,
                                  deathLocation: deathLocation,
                                  marriageStatus: marriageStatus,
                                  bio: bio,
                                  graveLocationLatitude: graveLocationLatitude,
                                  graveLocationLongitude: graveLocationLongitude)
                
                let graveRef = self.db.collection("grave")
                graveRef.whereField("graveId", isEqualTo: grave.graveId).getDocuments { (snapshot, error) in
                    if error != nil {
                        print(Error.self)
                    } else {
                        if snapshot?.description == grave.graveId {
                            grave.graveId = newGraveId
                        } else {
                            print("no dupli")
                        }
                    }
                }
                graveRef.document(String(grave.graveId)).setData(grave.dictionary) { err in
                    if let err = err {
                        let graveCreationFailAert = UIAlertController(title: "Failed to create a Grave", message: "Your device failed to properly create a Grave on your desired destination, Please check your wifi and try again", preferredStyle: .alert)
                        let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
                        graveCreationFailAert.addAction(dismiss)
                        self.present(graveCreationFailAert, animated: true, completion: nil)
                        print(err)
                    } else {
                        self.performSegue(withIdentifier: "segueToGrave", sender: nil)
                        print("Added Data")
                    }
                }
            }
            
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
