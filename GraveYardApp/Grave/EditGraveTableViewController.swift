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
import GoogleSignIn

class EditGraveTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var graveMainImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var familyStatusTextField: UITextField!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var birthLocationTextField: UITextField!
    @IBOutlet weak var deathDatePicker: UIDatePicker!
    @IBOutlet weak var deathLocationTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentUser: Grave?
    var userId: String?
    var creatorId: String? = ""
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        chageTextColor()
        db = Firestore.firestore()
        getGraveData()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError()
        }
        graveMainImage.image = selectedImage
        dismiss(animated: true, completion: nil)
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
                    if let name = document.data()["name"] as? String,
                        let birthDate = document.data()["birthDate"] as? String,
                        let birthLocation = document.data()["birthLocation"] as? String,
                        let deathDate = document.data()["deathDate"] as? String,
                        let deathLocation = document.data()["deathLocation"] as? String,
//                        let familyStatus = document.data()["familyStatus"] as? String,
                        let bio = document.data()["bio"] as? String {

                        guard let birthDate = self.dateFormatter.date(from:birthDate) ?? defaultDate else { return } // this fails atm
                        guard let deathDate = self.dateFormatter.date(from:deathDate) ?? defaultDate else { return }
                        self.nameTextField.text = name
                        self.birthDatePicker.date = birthDate
                        self.birthLocationTextField.text = birthLocation
                        self.deathDatePicker.date = deathDate
                        self.deathLocationTextField.text = deathLocation
//                        self.familyStatusTextField.text = familyStatus
                        self.bioTextView.text = bio
                    }
                }
            }
        }
    }
    
    struct PropertyKeys {
        static let unwind = "unwindToGraveSegue"
    }
    
    // MARK: - Actions
    
    @IBAction func saveGraveInfoTapped(_ sender: UIBarButtonItem) {
        let id = currentAuthID!
        guard let graveId = MapViewController.shared.currentGraveId  else { return } // this is the grave id that was tapped on
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
        
        let grave = Grave(creatorId: id,
                          graveId: graveId,
                          name: name,
                          birthDate: birthDate,
                          birthLocation: birthLocation,
                          deathDate: deathDate,
                          deathLocation: deathLocation,
//                          familyStatus: familyStatus,
                          bio: bio,
                          graveLocationLatitude: graveLocationLatitude,
                          graveLocationLongitude: graveLocationLongitude)
        
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
