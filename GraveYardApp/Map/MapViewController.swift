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
import AVKit
import AVFoundation
import GoogleSignIn

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var friendRequestNotificationButton: UIButton!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var playHowToMemorialVideoButton: UIButton!
    @IBOutlet weak var howToMemorialPreviewImage: UIImageView!
    @IBOutlet weak var recenterMapButton: UIButton!
    @IBOutlet weak var signUp: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var addMemorialView: UIView!
    @IBOutlet weak var yourMemorialsButton: UIButton!
    @IBOutlet weak var bookSideExpandButton: UIButton!
    @IBOutlet weak var bookSideUIView: UIView!
    @IBOutlet weak var bookSideUIImageView: UIImageView!
    
    // MARK: - Propeties
    
    private var mapChangedFromUserInteraction = false
    static let shared = MapViewController()
    var resultSearchController: UISearchController? = nil
    var currentAuthID = Auth.auth().currentUser?.uid
    var userId: String = ""
    var currentUser: User?
    var locationManager = CLLocationManager()
    var regionInMeters: Double = 10000.0
    var db = Firestore.firestore()
    var currentGraveId: String?
    var creatorId: String?
    var graveId: String?
    var currentGraveLocationLatitude: String?
    var currentGraveLocationLongitude: String?
    var graves: [Grave]?
    var graveAnnotationCoordinates: String?
    var selectedAnnotation: GraveEntryAnnotation?
    var bookSideHasExpanded: Bool = false
    var playerLayer: AVPlayer?
    var friendRequests: Array<String>?

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.locationManager.distanceFilter = 90000.0;
//        self.mapView.removeAnnotations(self.mapView.annotations)
        setMapViewLocationAndUser()
        //chageTextColor()
        self.recenterMapButton.layer.cornerRadius = 10
        addMemorialView.layer.cornerRadius = 10
        playHowToMemorialVideoButton.layer.cornerRadius = 10
        mapView.delegate = self
        friendRequestNotificationButton.layer.cornerRadius = 22
        friendRequestNotificationButton.isHidden = true
        getUserData()
//        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.title = "Account"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        getGraveEntries { (graves) in
            self.graves = graves
            self.dropGraveEntryPins()
         }
        checkForUserId()// make sure this gets calld everytime u reload from sign in
    }
    
    // MARK: - Functions
    
    func chageTextColor() {
        navigationItem.leftBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
    }
    
    func checkForUserId() {
        if currentAuthID == nil {
            signUp.title = "Sign In"
        } else {
            signUp.title = "Log Out"
        }
    }
    
    func playHowToMemorial() { // duo
        let videoURL: URL = Bundle.main.url(forResource: "name of video here", withExtension: "mp4")!
        let player = AVPlayer(url: videoURL)
        let vc = AVPlayerViewController()
        vc.player = player
        self.present(vc, animated: true) { vc.player?.play() }
    }
    
    func getUserMemorialCount() {

        guard let safeCurrentAuthID = self.currentAuthID else { return }
        let userRef = self.db.collection("userProfile").whereField("userAuthId", isEqualTo: safeCurrentAuthID)
        userRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    if let memorialCount = document.data()["memorialCount"] as? Int {
                        MyFirebase.memorialCount = memorialCount
                        switch MyFirebase.memorialCount {
                        case 0:
                            self.yourMemorialsButton.setTitle("How to Create Memorials", for: .normal)
                        default:
                            self.yourMemorialsButton.setTitle("Your Memorial Sites", for: .normal)
                        }
                    }
                }
            }
        }
    }
    
    func updateUserMemorialCount() {
        guard let currentId = currentAuthID else { return }
        MyFirebase.memorialCount += 1
        db.collection("userProfile").document(currentId).updateData([
            "memorialCount": MyFirebase.memorialCount
        ]) { err in
            if let err = err {
                MyFirebase.memorialCount -= 1
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func dropGraveEntryPins() {
        if graves != nil && graves?.count != 0 {
            for i in 0...graves!.count - 1 {
//            for i in stride(from: 0, through: graves!.count - 1, by: -1) {
                let registeredGrave = graves![i]
                let annotation = MKPointAnnotation()
                var currentGraveTitle: String = ""
                var pinQuote: String = ""
                if registeredGrave.publicIsTrue == false && self.currentAuthID != registeredGrave.creatorId {
                    currentGraveTitle = "Private"
                    pinQuote = ""
                } else {
                    currentGraveTitle = registeredGrave.name
                    pinQuote = "\(registeredGrave.pinQuote)"
                }
                if currentGraveTitle.isEmpty == true {
                    currentGraveTitle = "New Entry"
                }
                let currentGraveId = registeredGrave.graveId
                guard let graveLatitude = Double(registeredGrave.graveLocationLatitude),
                    let graveLongitude = Double(registeredGrave.graveLocationLongitude) else {
                        print("We don't have coordinates yet")
                        return }
                let graveCoordinates = CLLocationCoordinate2D(latitude: graveLatitude, longitude: graveLongitude)
                //change subtitle to grave. quote. the quote will be blank for free users and premium will have the ability to change their quote
                let graveEntryAnnotation = GraveEntryAnnotation(annotation: annotation, coordinate: graveCoordinates, title: currentGraveTitle, subtitle: pinQuote, graveId: currentGraveId)
                
                annotation.coordinate = graveCoordinates //adds pins when you log in
                annotation.title = registeredGrave.name
                annotation.subtitle = pinQuote
                mapView.addAnnotation(graveEntryAnnotation)
                
            }
        }
    }
    
    func getGraveEntries(completion: @escaping ([Grave]) -> Void) {
        db.collection("grave").getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            var registeredGraves: [Grave] = []
            for i in snapshot.documents {
                let currentGrave = i.data()
                if let creatorId = currentGrave["creatorId"] as? String,
                    let graveId = currentGrave["graveId"] as? String,
                    let profileImageId = currentGrave["profileImageId"] as? String,
                    let name = currentGrave["name"] as? String,
                    let birthDate = currentGrave["birthDate"] as? String,
                    let birthLocation = currentGrave["birthLocation"] as? String,
                    let deathDate = currentGrave["deathDate"] as? String,
                    let deathLocation = currentGrave["deathLocation"] as? String,
                    let familyStatus = currentGrave["familyStatus"] as? String,
                    let bio = currentGrave["bio"] as? String,
                    let graveLocationLatitude = currentGrave["graveLocationLatitude"] as? String,
                    let graveLocationLongitude = currentGrave["graveLocationLongitude"] as? String,
                    let allGraveIdentifier = currentGrave["allGraveIdentifier"] as? String,
                    let pinQuote = currentGrave["pinQuote"] as? String,
                    let birthSwitchIsOn = currentGrave["birthSwitchIsOn"] as? Bool,
                    let deathSwitchIsOn = currentGrave["deathSwitchIsOn"] as? Bool,
                    let publicIsTrue = currentGrave["publicIsTrue"] as? Bool,
                    let videoURL = currentGrave["videoURL"] as? String,
                    let storyCount = currentGrave["storyCount"] as? Int,
                    let arrayOfStoryImageIDs = currentGrave["arrayOfStoryImageIDs"] as? [String] {
                    
                    let registeredGrave = Grave(creatorId: creatorId,
                                                graveId: graveId,
                                                profileImageId: profileImageId,
                                                name: name,
                                                birthDate: birthDate,
                                                birthLocation: birthLocation,
                                                deathDate: deathDate,
                                                deathLocation: deathLocation,
                                                familyStatus: familyStatus,
                                                bio: bio,
                                                graveLocationLatitude: graveLocationLatitude,
                                                graveLocationLongitude: graveLocationLongitude,
                                                allGraveIdentifier: allGraveIdentifier,
                                                pinQuote: pinQuote,
                                                birthSwitchIsOn: birthSwitchIsOn,
                                                deathSwitchIsOn: deathSwitchIsOn,
                                                publicIsTrue: publicIsTrue,
                                                videoURL: videoURL,
                                                storyCount: storyCount,
                                                arrayOfStoryImageIDs: arrayOfStoryImageIDs)
                    
                    registeredGraves.append(registeredGrave)
                    print(registeredGraves)
                }
            }
            completion(registeredGraves)
        }
//        var graveArray = [Grave]()
//        db.collection("stories").whereField("allGraveIdentifier", isEqualTo: "tylerRoolz" ).getDocuments { (snapshot, error) in
//            if error != nil {
//                print(Error.self)
//            } else {
//                guard let snapshot = snapshot else {
//                    print("could not unrwap snapshot")
//                    return
//                }
//                for document in (snapshot.documents) {
//                    //do an if let statement for every value in the grave object and then set it to the check out the tableview
//                    guard let name = document.data()["name"] as? String,
//                        let birthDate = document.data()["birthDate"] as? String,
//                        let deathDate = document.data()["deathDate"] as? String else {
//                            print("name, birthDate, or deathDate is not working")
//                            return }
//
//
//                    if let graveResult = document.data() as? [String: Any], let graveStories = Grave.init(dictionary: graveResult) {
//                        graveArray.append(graveStories)
////                    }
//                }
//                self.graves = graveArray
//                print("This is working")
//                print(self.graves)
////                DispatchQueue.main.async {
////
//                }
//            }
//        }
    }
    
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        return setGraveEntryPin(annotation: annotation)
    }
    
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        self.selectedAnnotation = view.annotation as? GraveEntryAnnotation
//        self.currentGraveId = self.selectedAnnotation?.graveId
//        print("you tapped on \(view.annotation?.title)")
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.selectedAnnotation = view.annotation as? GraveEntryAnnotation
        MapViewController.shared.currentGraveId = self.selectedAnnotation?.graveId
        performSegue(withIdentifier: "segueToGrave", sender: self)
    }
    
    func setGraveEntryPin(annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "entryPin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKMarkerAnnotationView?
        pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        pinView??.glyphImage = UIImage(named: "genericEntryGlyph")
        pinView??.markerTintColor = #colorLiteral(red: 0.1201040372, green: 0.8558169007, blue: 0.5233284831, alpha: 1)
        let pinButton = UIButton(type: .infoDark) as UIButton
        pinView??.rightCalloutAccessoryView = pinButton
        pinView??.canShowCallout = true
        //make a check here for if the user is premium if they are then  the image will change other wise it will be  adefault image from us
        //pinView??.image = UIImage(named: <#T##String#>)
        
        return pinView ?? nil
    }
    
    func setMapViewLocationAndUser() {
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
//            locationManager.stopUpdatingLocation()
            self.mapView.showsUserLocation = true
        }
        mapView.showsScale = true
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        mapView.userTrackingMode = .follow
        mapView.isUserInteractionEnabled = true
    }

    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizer.State.began || recognizer.state == UIGestureRecognizer.State.ended ) {
                    return true
                }
            }
        }
        return false
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
        if (mapChangedFromUserInteraction) {
            // user changed map region
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if (mapChangedFromUserInteraction) {
            // user changed map region
        }
    }
    
    func showPopOverAnimate() {
        self.addMemorialView.center = self.view.center
        self.addMemorialView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.addMemorialView.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.addMemorialView.alpha = 1.0
            self.addMemorialView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
//        self.playVideo()
    }
    
    func removePopOverAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.addMemorialView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.addMemorialView.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished) {
                self.addMemorialView.removeFromSuperview()
            }
        });
    }
    
    func moveBookSidetoLeft() {
        self.bookSideHasExpanded = false
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        let moveLeft = CGAffineTransform(translationX: 0, y: 0)
                        self.bookSideUIView.transform = moveLeft
        }) {
            (_) in
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToGrave", let graveTVC = segue.destination as? GraveTableViewController {
            graveTVC.currentGraveId = MapViewController.shared.currentGraveId
        } else if segue.identifier == "segueToFriendRequest", let accountTVC = segue.destination as? AccountTableViewController {
            accountTVC.friendListIsExpanded = true
        }
    }
    
    func playVideo() { // duo of another same one dlelte one
        guard let path = Bundle.main.path(forResource: "memorialMakerInto", ofType:"mp4") else {
            debugPrint("video not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
    
    func getUserData() {
        if self.currentAuthID == nil {
            self.yourMemorialsButton.setTitle("How to Create Memorials", for: .normal)
        }
        guard let currentUserAuthID: String = self.currentAuthID else { return }
        let userRef = self.db.collection("userProfile").whereField("userAuthId", isEqualTo: currentUserAuthID)
        userRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    if let premiumStatus = document.data()["premiumStatus"] as? Int,
                       let friendRequests = document.data()["friendRequests"] as? Array<String>,
                       let memorialCount = document.data()["memorialCount"] as? Int {
                        MyFirebase.memorialCount = memorialCount
                        self.friendRequests = friendRequests
                        print(friendRequests.count)
                        if friendRequests.count > 0 {
                            self.friendRequestNotificationButton.isHidden = false
                        }
                        switch MyFirebase.memorialCount {
                        case 0:
                            self.yourMemorialsButton.setTitle("How to Create Memorials", for: .normal)
                        default:
                            self.yourMemorialsButton.setTitle("Your Memorial Sites", for: .normal)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func recenterButtonTapped(_ sender: Any) {
        self.mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        mapView.userTrackingMode = .follow
    }
    
    @IBAction func closeMemorialHelperButtonTapped(_ sender: UIButton) {
        removePopOverAnimate()
    }
    
    @IBAction func userDidLongPress(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: self.mapView)
        let locationCoordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        print(annotation.coordinate)
        annotation.title = "New Entry"
        self.mapView.addAnnotation(annotation)
//        let annotationCoordinates = mapView.annotations.last
        let annotationLat = annotation.coordinate.latitude
        let annotationLong = annotation.coordinate.longitude
        
        var alertStyle = UIAlertController.Style.alert
        if (UIDevice.current.userInterfaceIdiom == .pad) {
          alertStyle = UIAlertController.Style.alert
        }
        let newGraveAlert = UIAlertController(title: "New Memorial", message: "Would you like to make a new entry at this location?", preferredStyle: alertStyle)
        newGraveAlert.addAction(UIAlertAction(title: "Create new entry", style: .default, handler: { action in
            print("Default Button Pressed")
            
            if self.currentAuthID == nil {
                for annotation in self.mapView.annotations {
                    if annotation.title == "New Entry" {
                        self.mapView.removeAnnotation(annotation)
                    }
                }
                let notSignInAlert = UIAlertController(title: "You are not signed in", message: "You must sign in to create a Memorial  at this location", preferredStyle: alertStyle)
                let dismiss = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                notSignInAlert.addAction(dismiss)
                let goToLogIn = UIAlertAction(title: "Sign In", style: .default, handler: { _ in
                    self.moveBookSidetoLeft()
                    self.performSegue(withIdentifier: "unwindToSignIn", sender: nil)
                })
                notSignInAlert.addAction(goToLogIn)
                self.present(notSignInAlert, animated: true, completion: nil)
            } else {
                let memorialCount = MyFirebase.memorialCount
                guard memorialCount < 15 else {
                    let graveCreationFailAlert = UIAlertController(title: "Too many Memorials", message: "You are only allowed 15 Memorials.", preferredStyle: alertStyle)
//                    let graveCreationFailAlert = UIAlertController(title: "Too many Memorials", message: "Free users are only allowed 3 Memorials. To increase the amount, subscribe and get premium benefits.", preferredStyle: .alert)
                    let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
                    graveCreationFailAlert.addAction(dismiss)
                    self.present(graveCreationFailAlert, animated: true, completion: nil)
                    for annotation in self.mapView.annotations {
                        if annotation.title == "New Entry" {
                            self.mapView.removeAnnotation(annotation)
                        }
                    }
                    return
                }
                let id = self.currentAuthID!
                MapViewController.shared.currentGraveId = UUID().uuidString
                MapViewController.shared.currentGraveLocationLatitude = String(annotationLat)
                MapViewController.shared.currentGraveLocationLongitude = String(annotationLong)
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                let formattedDate = dateFormatter.string(from: date)
                let newGraveId = UUID().uuidString
                let profileImageId: String = UUID().uuidString
                let name: String = ""
                let birthDate: String = formattedDate
                let birthLocation: String = ""
                let deathDate: String = formattedDate
                let deathLocation: String = ""
                let familyStatus: String = ""
                let bio: String = ""
                let pinQuote: String = ""
                let allGraveIdentifier = "tylerRoolz"
                let birthSwitchIsOn: Bool = true
                let deathSwitchIsOn: Bool = true
                let publicIsTrue: Bool = true
                let videoURL: String = UUID().uuidString + ".mp4"
                let arrayOfStoryImageIDs: [String] = [""]
                let storyCount: Int = 0
                guard let graveId: String = MapViewController.shared.currentGraveId else { return }
                guard let graveLocationLatitude: String = MapViewController.shared.currentGraveLocationLatitude else { return }
                guard let graveLocationLongitude: String = MapViewController.shared.currentGraveLocationLongitude else { return }
                
                var grave = Grave(creatorId: id,
                                  graveId: graveId,
                                  profileImageId: profileImageId,
                                  name: name,
                                  birthDate: birthDate,
                                  birthLocation: birthLocation,
                                  deathDate: deathDate,
                                  deathLocation: deathLocation,
                                  familyStatus: familyStatus,
                                  bio: bio,
                                  graveLocationLatitude: graveLocationLatitude,
                                  graveLocationLongitude: graveLocationLongitude,
                                  allGraveIdentifier: allGraveIdentifier,
                                  pinQuote: pinQuote,
                                  birthSwitchIsOn: birthSwitchIsOn,
                                  deathSwitchIsOn: deathSwitchIsOn,
                                  publicIsTrue: publicIsTrue,
                                  videoURL: videoURL,
                                  storyCount: storyCount,
                                  arrayOfStoryImageIDs: arrayOfStoryImageIDs)
                
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
                        var alertStyle = UIAlertController.Style.actionSheet
                        if (UIDevice.current.userInterfaceIdiom == .pad) {
                          alertStyle = UIAlertController.Style.alert
                        }
                        let graveCreationFailAlert = UIAlertController(title: "Failed to create a Memorial", message: "Your device failed to properly create a Memorial on your desired destination, Please check your wifi and try again", preferredStyle: alertStyle)
                        let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
                        graveCreationFailAlert.addAction(dismiss)
                        self.present(graveCreationFailAlert, animated: true, completion: nil)
                        print(err)
                    } else {
                        print("Added Data")
                        self.moveBookSidetoLeft()
                        self.updateUserMemorialCount()
                        self.performSegue(withIdentifier: "segueToGrave", sender: nil)
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
           self.moveBookSidetoLeft()
            performSegue(withIdentifier: "unwindToSignIn", sender: self)
        } else {
            var alertStyle = UIAlertController.Style.actionSheet
            if (UIDevice.current.userInterfaceIdiom == .pad) {
              alertStyle = UIAlertController.Style.alert
            }
            let locationAlert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: alertStyle)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            locationAlert.addAction(cancelAction)
            
            let goToSettingsAction = UIAlertAction(title: "Log Out", style: .default, handler: { _ in
                self.moveBookSidetoLeft()
                GIDSignIn.sharedInstance().signOut()
                self.currentUser = nil
                self.userId = ""
                try! Auth.auth().signOut()
                self.currentAuthID = nil
                MyFirebase.memorialCount = 0
                self.checkForUserId()
            })
            locationAlert.addAction(goToSettingsAction)
            present(locationAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func AccountSideBarButtonItemTapped(_ sender: UIBarButtonItem) {
    
        if currentAuthID != nil {
            self.moveBookSidetoLeft()
            performSegue(withIdentifier: "segueToAccount", sender: nil)
        } else {
            let notSignInAlert = UIAlertController(title: "You are not signed in", message: "You must be signed in to check account information", preferredStyle: .actionSheet)
            let dismiss = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            notSignInAlert.addAction(dismiss)
            let goToLogIn = UIAlertAction(title: "Sign In", style: .default, handler: { _ in
                self.moveBookSidetoLeft()
                self.performSegue(withIdentifier: "unwindToSignIn", sender: nil)
            })
            notSignInAlert.addAction(goToLogIn)
            self.present(notSignInAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func yourMemorialsButtonWasTapped(_ sender: UIButton) {
        if MyFirebase.memorialCount == 0 {
            self.view.addSubview(addMemorialView)
            showPopOverAnimate()
        } else {
            self.moveBookSidetoLeft()
            performSegue(withIdentifier: "viewOwnMemorialsSegue", sender: nil)
        }
    }
    
    @IBAction func bookSideExpandButtonWasTapped(_ sender: UIButton) {
        if self.bookSideHasExpanded == false {
            self.bookSideHasExpanded = true
            UIView.animate(withDuration: 0.4,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: {
                            let moveRight = CGAffineTransform(translationX: 250, y: 0)
                            self.bookSideUIView.transform = moveRight
            }) {
                (_) in
            }
        } else if self.bookSideHasExpanded == true {
            self.bookSideHasExpanded = false
            UIView.animate(withDuration: 0.4,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: {
                            let moveLeft = CGAffineTransform(translationX: 0, y: 0)
                            self.bookSideUIView.transform = moveLeft
            }) {
                (_) in
            }
        }
    }
    
    @IBAction func howToMemorialButtonWasTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func playHowToVideoWasTapped(_ sender: UIButton) {
        self.playVideo()
    }
    
    @IBAction func unwindToMap(_ sender: UIStoryboardSegue) {}
    
    @IBAction func friendRequestNotificationButtonWasTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "segueToFriendRequest", sender: nil)
    }
    
}


extension MapViewController {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
//        guard let location = locations.last else { return }
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        mapView.setRegion(region, animated: true)
        
        //lock on location, disabled go let user view around more
//        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        //print("The user location coordinates are \(locValue.latitude) \(locValue.longitude)") // this is getting spam called!!!!!
//        let userLocation = locations.last
//        let viewRegion = MKCoordinateRegion(center: (userLocation?.coordinate)!, latitudinalMeters: 600, longitudinalMeters: 600)
//        mapView.setRegion(viewRegion, animated: true)
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }
    
    func updateSearchResults(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, err) in
            if response == nil {
                print("ERROR: \(err)")
            } else {
                
            }
        }
    }
    
}
