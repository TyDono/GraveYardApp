//
//  EditGraveTableViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/28/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import AVKit
import AVFoundation

class EditGraveTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var deleteHeadstoneButton: UIButton!
    @IBOutlet weak var graveMainImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var birthLocationTextField: UITextField!
    @IBOutlet weak var deathDatePicker: UIDatePicker!
    @IBOutlet weak var deathLocationTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var pinQuoteTextField: UITextField!
    @IBOutlet weak var familyStatusTextView: UITextView!
    
    // MARK: - Propeties
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentUser: Grave?
    var userId: String?
    var creatorId: String?
    let dateFormatter = DateFormatter()
    var imageString: String?
    var currentGraveId: String?
    var graveProfileImage: GraveProfileImage?
    var graveProfileImages = [UIImage]()
    var currentGraveLocationLongitude: String?
    var currentGraveLocationLatitude: String?
    let storage = Storage.storage()
    var currentImageDataCount: Int?
    var player = AVPlayer()
    var playerViewController = AVPlayerViewController()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //chageTextColor()
        self.deleteHeadstoneButton.layer.cornerRadius = 10
        db = Firestore.firestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getGraveData()
    }
    
    // MARK: - Functions
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            graveMainImage.image = selectedImage
            graveProfileImages.append(selectedImage)
            dismiss(animated: true, completion: nil)
            self.graveMainImage.reloadInputViews()
        }
    }
    
    func chageTextColor() {
        tableView.separatorColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
    }
    
    func updateUserData() {
        db = Firestore.firestore()
        guard let currentId = currentAuthID else { return }
        db.collection("userProfile").document(currentId).updateData([
            "dataCount": MyFirebase.currentDataUsage!
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func getGraveData() { // mak srue to change the sting back to a date here
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let defaultDate: Date? = self.dateFormatter.date(from: "1993-08-05") // this is nil atm
        let graveRef = self.db.collection("grave").whereField("graveId", isEqualTo: MapViewController.shared.currentGraveId!) // this should be the grave id that was tapped on
        graveRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    if let creatorId = document.data()["creatorId"] as? String,
                        let profileImageId = document.data()["profileImageId"] as? String,
                        let name = document.data()["name"] as? String,
                        let birthDate = document.data()["birthDate"] as? String,
                        let birthLocation = document.data()["birthLocation"] as? String,
                        let deathDate = document.data()["deathDate"] as? String,
                        let deathLocation = document.data()["deathLocation"] as? String,
                        let graveId = document.data()["graveId"] as? String?,
                        let familyStatus = document.data()["familyStatus"] as? String,
                        let bio = document.data()["bio"] as? String,
                        let pinQuote = document.data()["pinQuote"] as? String,
                        let graveLocationLatitude = document.data()["graveLocationLatitude"] as? String,
                        let graveLocationLongitude = document.data()["graveLocationLongitude"] as? String {
                        
                        self.imageString = profileImageId
                        guard let birthDate = self.dateFormatter.date(from:birthDate) ?? defaultDate else { return }
                        guard let deathDate = self.dateFormatter.date(from:deathDate) ?? defaultDate else { return }
                        self.nameTextField.text = name
                        self.birthDatePicker.date = birthDate
                        self.birthLocationTextField.text = birthLocation
                        self.deathDatePicker.date = deathDate
                        self.currentGraveId = graveId
                        self.deathLocationTextField.text = deathLocation
                        //self.familyStatusTextView.text = familyStatus
                        self.bioTextView.text = bio
                        self.pinQuoteTextField.text = pinQuote
                        self.creatorId = creatorId
                        self.currentGraveLocationLatitude = graveLocationLatitude
                        self.currentGraveLocationLongitude = graveLocationLongitude
                        self.getImages() //call this last
                    }
                }
            }
        }
    }
    
    func getStoryData() {
        let graveRef = self.db.collection("grave").whereField("graveId", isEqualTo: MapViewController.shared.currentGraveId)
        graveRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    if let creatorId = document.data()["creatorId"] as? String {

                    }
                }
            }
        }
    }
    
    func getImages() {
        if let imageStringId = self.imageString {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("graveProfileImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
                guard let data = data else { return }
                guard let image = UIImage(data: data) else { return }
                self.graveMainImage.image = image
                guard let imageDataBytes = image.jpegData(compressionQuality: 0.20) else { return }
                self.currentImageDataCount = imageDataBytes.count
            })
        } else {
            return
        }
    }
    
    func uploadFirebaseImages(_ image: UIImage, completion: @escaping ((_ url: URL?) -> () )) {
        let storageRef = Storage.storage().reference().child("graveProfileImages/\(self.imageString ?? "no Image Found")")
        guard let imageData = image.jpegData(compressionQuality: 0.20) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            if error == nil, metaData != nil {
                print("got grave image")
                storageRef.downloadURL(completion: { (url, error) in
                    completion(url)
                })
            } else {
                completion(nil)
            }
        }
    }
    
//    private func firebaseWrite(url: String) {
//        var ref: DocumentReference? = nil
//        ref = db.collection("grave").addDocument(data: [
//            "imageURL": url
//        ]) { err in
//            if let err = err {
//                print("Error adding document: \(err)")
//            } else {
//                print("Document added with ID: \(ref!.documentID)")
//            }
//        }
//
//        db.collection("grave").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                }
//            }
//        }
//    }
    
    func saveImageToFirebase(graveImagesURL: URL, completion: @escaping((_ success: Bool) -> ())) {
        let databaseRef = Firestore.firestore().document("graveProfileImages/\(self.currentGraveId ?? "no image")")
        let userObjectImages = [
            "imageURL": graveImagesURL.absoluteString
        ] as [String:Any]
        databaseRef.setData(userObjectImages) { (error) in
            completion(error == nil)
        }
        print("SaveImageToFirebase has been saved!!!!!")
    }
    
    struct PropertyKeys {
        static let unwind = "unwindToGraveSegue"
    }
    
    func deleteGraveProfileImage() {
        let imageRef = self.storage.reference().child(self.imageString ?? "no image String found")
        imageRef.delete { err in
            if let error = err {
                let deleteImageAlert = UIAlertController(title: "Error", message: "Sorry, there was an error while trying to delete your Headstone Image. Please check your internet connection and try again.", preferredStyle: .alert)
                deleteImageAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    deleteImageAlert.dismiss(animated: true, completion: nil)
                }))
                self.present(deleteImageAlert, animated: true, completion: nil)
                print(error)
            } else {
                // File deleted successfully
            }
        }
    }
        
        func deleteGraveStories() {
            let graveStoryRef = self.db.collection("stories")
            
            let getStories = graveStoryRef.whereField("graveId", isEqualTo: self.currentGraveId)
            getStories.getDocuments { (snapshot, err) in
                if err != nil {
                    print(err as Any)
                } else {
                    for document in (snapshot?.documents)! {
    //                    if let creatorId = document.data()["creatorId"] as? String,
    //                        let profileImageId = document.data()["profileImageId"] as? String,
                    }
                }
                
            }
            
            graveStoryRef.document("").delete() {
                err in
                if err == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        moveToMap()
                    }
                }
            }
        }
    
    // MARK: - Actions
    
    @IBAction func saveGraveInfoTapped(_ sender: UIBarButtonItem) { //  MOST OF COMMENTED OUT CODE WILL BE RE-ADDED WHEN PREMIUM IS LIVE TO KEEP TRACK OF THEIR DATA USE AND TO LET THE USERS KNOW. ADD THIS TO NEWGRAVESTORYVIEWCONTROLLER WHEN PREMIUM IS LIVE
//        guard let unwrappedGraveImage = graveMainImage.image else { return } // the uplaod takes 2 long and needs a delay before segue is called
//        guard let currentDataUseCount = MyFirebase.currentDataUsage else { return }
//        var checkDataCap: Int = 0
        for image in graveProfileImages {
            uploadFirebaseImages(image) { (url) in
                guard let imageDataBytes = image.jpegData(compressionQuality: 0.20) else { return }
                if let unwrappedCurrentImageDataCount = self.currentImageDataCount {
//                    checkDataCap = currentDataUseCount - unwrappedCurrentImageDataCount + imageDataBytes.count
//                    if checkDataCap > 5000 {
//                        let alert = UIAlertController(title: "Over Limit!", message: "Saving this puts you over your alloted data use! Try deleting some photos to make room, or sign up for premium to expand your data cap for Remembrance.  current amount in use \(checkDataCap) / 5,000kb", preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
//                            alert.dismiss(animated: true, completion: nil)
//                            return
//                        }))
//                        self.present(alert, animated: true, completion: nil)
//                    } else {
                        MyFirebase.currentDataUsage = MyFirebase.currentDataUsage! - unwrappedCurrentImageDataCount + imageDataBytes.count
                        self.updateUserData()
//                    }
                }
                guard url != nil else { return }
//                self.saveImageToFirebase(graveImagesURL: url, completion: { success in
//                    self.firebaseWrite(url: url.absoluteString)
//                })
            }
        }
        
        let creatorId = currentAuthID!
        guard let graveId = self.currentGraveId  else { return } // this is the grave id that was tapped on
        guard let profileImageId = self.imageString else { return }
        guard let name = nameTextField.text else { return }
        let birth = birthDatePicker.date
        let birthDate = dateFormatter.string(from: birth)
        guard let birthLocation = birthLocationTextField.text else { return }
        let death = deathDatePicker.date
        let deathDate = dateFormatter.string(from: death)
        guard let deathLocation = deathLocationTextField.text else { return }
        let familyStatus =  "" //familyStatusTextView.text else { return }
        guard let bio = bioTextView.text else { return }
        guard let currentGraveLocationLatitude = self.currentGraveLocationLatitude  else { return }
        guard let currentGraveLocationLongitude = self.currentGraveLocationLongitude  else { return }
        let allGraveIdentifier: String = "tylerRoolz"
        guard let pinQuote: String = self.pinQuoteTextField.text else { return }
        
        let grave = Grave(creatorId: creatorId,
                          graveId: graveId,
                          profileImageId: profileImageId,
                          name: name,
                          birthDate: birthDate,
                          birthLocation: birthLocation,
                          deathDate: deathDate,
                          deathLocation: deathLocation,
                          familyStatus: familyStatus,
                          bio: bio,
                          graveLocationLatitude: currentGraveLocationLatitude,
                          graveLocationLongitude: currentGraveLocationLongitude,
                          allGraveIdentifier: allGraveIdentifier,
                          pinQuote: pinQuote)
        
        let graveRef = self.db.collection("grave")
        graveRef.document(String(grave.graveId)).updateData(grave.dictionary){ err in
            if let err = err {
                let alert1 = UIAlertController(title: "Not Saved", message: "Sorry, there was an error while trying to save your Grave. Please try again.", preferredStyle: .alert)
                alert1.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert1.dismiss(animated: true, completion: nil)
                }))
                self.present(alert1, animated: true, completion: nil)
                print(err)
            } else {
                let alert1 = UIAlertController(title: "Memorial Saved!", message: "You have successfully save your Memorial data", preferredStyle: .alert)
                alert1.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert1.dismiss(animated: true, completion: nil)
                    self.performSegue(withIdentifier: "unwindToGraveSegue", sender: nil)
                }))
                self.present(alert1, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func changeImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func deleteGraveButtonTapped(_ sender: UIButton) {
        let alerController = UIAlertController(title: "WARNING!", message: "This will delete all of the information on this Memorial!", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alerController.addAction(cancel)
        let delete = UIAlertAction(title: "DELETE", style: .destructive) { _ in
//            let userId = self.currentAuthID!
            let userRef = self.db.collection("stories")
            userRef.document(self.currentGraveId ?? "error no graveId found").delete() { err in
                if err == nil {
                    let storyRef = self.db.collection("grave")
                    storyRef.document(self.currentGraveId ?? "error no graveId found").delete() { err in
                        if err == nil {
                            self.deleteGraveProfileImage()
                            let alert1 = UIAlertController(title: "Success", message: "You have successfully deleted this Memorial", preferredStyle: .alert)
                            alert1.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                alert1.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert1, animated: true, completion: nil)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                                moveToMap()
                            }
                        } else {
                            let alert1 = UIAlertController(title: "ERROR", message: "Sorry, there was an error while trying to delete this Memorial, please check your internet connection  and try again", preferredStyle: .alert)
                            alert1.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                alert1.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert1, animated: true, completion: nil)
                            print("document not deleted, ERROR")
                        }
                    }
                    
                } else {
                    let alert1 = UIAlertController(title: "ERROR", message: "Sorry, there was an error while trying to delete this Memorial's stories, please check your internet connection  and try again", preferredStyle: .alert)
                    alert1.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        alert1.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert1, animated: true, completion: nil)
                    print("document not deleted, ERROR")
                    //                    print("Logged Out Tapped")
                    //                    self.currentUser = nil
                    //                    self.userId = ""
                    //                    try! Auth.auth().signOut()
                    //                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    //                        moveToLogIn()
                    //                    }
                }
            }
        }
        alerController.addAction(delete)
        self.present(alerController, animated: true) {
        }
    }
    
}
