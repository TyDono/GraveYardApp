//
//  EditGraveTableViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/28/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class EditGraveTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var graveMainImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var familyStatusTextField: UITextField!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var birthLocationTextField: UITextField!
    @IBOutlet weak var deathDatePicker: UIDatePicker!
    @IBOutlet weak var deathLocationTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var pinQuoteTextField: UITextField!
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentUser: Grave?
    var userId: String?
    var creatorId: String? = ""
    let dateFormatter = DateFormatter()
    var imageString: String?
    var currentGraveId: String?
    var graveProfileImage: GraveProfileImage?
    var graveProfileImages = [UIImage]()
    let storage = Storage.storage()

    override func viewDidLoad() {
        super.viewDidLoad()
        chageTextColor()
        db = Firestore.firestore()
//        getGraveData()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//            self.getImages()
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getGraveData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.getImages()
        }
    }
    
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
    
    func getGraveData() { // mak srue to change the sting back to a date here
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let defaultDate: Date? = self.dateFormatter.date(from: "1993-08-05") // this is nil atm
        let graveRef = self.db.collection("grave").whereField("graveId", isEqualTo: MapViewController.shared.currentGraveId) // this should be the grave id that was tapped on
        graveRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    if let profileImageId = document.data()["profileImageId"] as? String,
                        let name = document.data()["name"] as? String,
                        let birthDate = document.data()["birthDate"] as? String,
                        let birthLocation = document.data()["birthLocation"] as? String,
                        let deathDate = document.data()["deathDate"] as? String,
                        let deathLocation = document.data()["deathLocation"] as? String,
                        let graveId = document.data()["graveId"] as? String?,
//                        let familyStatus = document.data()["familyStatus"] as? String,
                        let bio = document.data()["bio"] as? String,
                        let pinQuote = document.data()["pinQuote"] as? String {
                        
                        self.imageString = profileImageId
                        guard let birthDate = self.dateFormatter.date(from:birthDate) ?? defaultDate else { return }
                        guard let deathDate = self.dateFormatter.date(from:deathDate) ?? defaultDate else { return }
                        self.nameTextField.text = name
                        self.birthDatePicker.date = birthDate
                        self.birthLocationTextField.text = birthLocation
                        self.deathDatePicker.date = deathDate
                        self.currentGraveId = graveId
                        self.deathLocationTextField.text = deathLocation
//                        self.familyStatusTextField.text = familyStatus
                        self.bioTextView.text = bio
                        self.pinQuoteTextField.text = pinQuote
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
                guard let data = data else {return}
                guard let image = UIImage(data: data) else {return}
                self.graveMainImage.image = image
            })
        } else {
            return
        }
    }
    
    func uploadFirebaseImages(_ image: UIImage, completion: @escaping ((_ url: URL?) -> () )) {
        let storageRef = Storage.storage().reference().child("graveProfileImages/\(self.imageString ?? "no Image Found")")
        guard let imageData = image.jpegData(compressionQuality: 0.25) else { return }
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
    
    // MARK: - Actions
    
    @IBAction func saveGraveInfoTapped(_ sender: UIBarButtonItem) {
//        guard let unwrappedGraveImage = graveMainImage.image else { return }
        for image in graveProfileImages {
            uploadFirebaseImages(image) { (url) in
                print(url)
                guard let url = url else { return }
//                self.saveImageToFirebase(graveImagesURL: url, completion: { success in
//                    self.firebaseWrite(url: url.absoluteString)
//                })
            }
        }
        
        let id = currentAuthID!
        guard let graveId = MapViewController.shared.currentGraveId  else { return } // this is the grave id that was tapped on
        guard let profileImageId = self.imageString else { return }
        guard let name = nameTextField.text else { return }
        let birth = birthDatePicker.date
        let birthDate = dateFormatter.string(from: birth)
        guard let birthLocation = birthLocationTextField.text else { return }
        let death = deathDatePicker.date
        let deathDate = dateFormatter.string(from: death)
        guard let deathLocation = deathLocationTextField.text else { return }
//        guard let familyStatus = familyStatusTextField.text else { return }
        guard let bio = bioTextView.text else { return }
        guard let graveLocationLatitude = MapViewController.shared.currentGraveLocationLatitude  else { return }
        guard let graveLocationLongitude = MapViewController.shared.currentGraveLocationLongitude  else { return }
        let allGraveIdentifier: String = "tylerRoolz"
        guard let pinQuote: String = self.pinQuoteTextField.text else { return }
        
        let grave = Grave(creatorId: id,
                          graveId: graveId,
                          profileImageId: profileImageId,
                          name: name,
                          birthDate: birthDate,
                          birthLocation: birthLocation,
                          deathDate: deathDate,
                          deathLocation: deathLocation,
//                          familyStatus: familyStatus,
                          bio: bio,
                          graveLocationLatitude: graveLocationLatitude,
                          graveLocationLongitude: graveLocationLongitude,
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
                self.performSegue(withIdentifier: "unwindToGraveSegue", sender: nil)
            }
        }
    }
    
    @IBAction func changeImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
}
