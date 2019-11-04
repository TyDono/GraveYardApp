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

class EditGraveTableViewController: UITableViewController {
    @IBOutlet weak var graveMainImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var marriageStatusTextField: UITextField!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var birthLocationTextField: UITextField!
    @IBOutlet weak var deathDatePicker: UIDatePicker!
    @IBOutlet weak var deathLocationTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentUser: Grave?
    var userId: String?
    let dateFormatter = DateFormatter()
    var currentGraveLocation: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        getGraveData()
    }
    
    func getGraveData() { // mak srue to change the sting back to a date here
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let defaultDate: Date? = self.dateFormatter.date(from: "1993-08-05")
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
                        let marriageStatus = document.data()["marriageStatus"] as? String,
                        let bio = document.data()["bio"] as? String {

                        guard let birthDate = self.dateFormatter.date(from:birthDate) ?? defaultDate else { return } // this fails atm
                        guard let deathDate = self.dateFormatter.date(from:deathDate) ?? defaultDate else { return }
                        self.nameTextField.text = name
                        self.birthDatePicker.date = birthDate
                        self.birthLocationTextField.text = birthLocation
                        self.deathDatePicker.date = deathDate
                        self.deathLocationTextField.text = deathLocation
                        self.marriageStatusTextField.text = marriageStatus
                        self.bioTextView.text = bio
                    }
                }
            }
        }
    }
    
    @IBAction func saveGraveInfoTapped(_ sender: UIBarButtonItem) {
        let id = currentAuthID!
        guard let graveId = MapViewController.shared.currentGraveId  else { return }// this is the grave id that was tapped on
        guard let name = nameTextField.text else { return }
        let birth = birthDatePicker.date
        let birthDate = dateFormatter.string(from: birth)
        guard let birthLocation = birthLocationTextField.text else { return }
        let death = deathDatePicker.date
        let deathDate = dateFormatter.string(from: death)
        guard let deathLocation = deathLocationTextField.text else { return }
        guard let marriageStatus = marriageStatusTextField.text else { return }
        guard let bio = bioTextView.text else { return }
        guard let currentGraveLocation = currentGraveLocation else { return }
        
        let grave = Grave(creatorId: id,
                          graveId: graveId,
                          name: name,
                          birthDate: birthDate,
                          birthLocation: birthLocation,
                          deathDate: deathDate,
                          deathLocation: deathLocation,
                          marriageStatus: marriageStatus,
                          bio: bio,
                          graveLocation: currentGraveLocation)
        
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
                let alert2 = UIAlertController(title: "Saved", message: "Your Grave has been saved", preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert2.dismiss(animated: true, completion: nil)
                }))
                self.present(alert2, animated: true, completion: nil)
                //self.profileInfo()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                }
            }
        }
    }

}
