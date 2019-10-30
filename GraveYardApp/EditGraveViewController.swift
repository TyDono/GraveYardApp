//
//  EditGraveViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/30/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class EditGraveViewController: UIViewController {
    @IBOutlet weak var graveMainImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var marriageStatusTextField: UITextField!

    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var birthLocationTextField: UITextField!

    @IBOutlet weak var deathDatePicker: UIDatePicker!
    @IBOutlet weak var deadLocationTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentUser: Grave?
    var userId: String?
    let formatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        //changeBackground()
        getGraveData()
    }

    func changeBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "GradientPlaceHolder")
        backgroundImage.contentMode = UIView.ContentMode.scaleToFill
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
   func getGraveData() {
        guard let uId: String = self.currentAuthID else { return }
        print("this is my uid i really like my uid \(uId)")
        let graveRef = self.db.collection("grave").whereField("id", isEqualTo: uId) // this should ne th grave id thsat was tapped on
        graveRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    if let name = document.data()["name"] as? String,
                        let birthDate = document.data()["birthDate"] as? Date,
                        let birthLocation = document.data()["birthLocation"] as? String,
                        let deathDate = document.data()["deathDate"] as? Date,
                        let deathLocation = document.data()["deathLocation"] as? String,
                        let bio = document.data()["bio"] as? String {
                        
                        self.nameTextField.text = name
                        self.birthDatePicker.date = birthDate
                        self.birthLocationTextField.text = birthLocation
                        self.deathDatePicker.date = deathDate
                        self.deadLocationTextField.text = deathLocation
                        self.marriageStatusTextField.text = bio
                    }
                }
            }
        }
    }
    
    @IBAction func saveGraveInfoTapped(_ sender: UIBarButtonItem) {
        let id = currentAuthID!
        let graveId = "" // this is the grave id that was tapped on
        guard let name = nameTextField.text else { return }
        let birth = birthDatePicker.date
        let birthDate = formatter.string(from: birth)
        let birthLocation = ""
        let death = deathDatePicker.date
        let deathDate = formatter.string(from: death)
        let deathLocation = ""
        guard let marriageStatus = marriageStatusTextField.text else { return }
        guard let bio = bioTextView.text else { return }
        
        let grave = Grave(creatorId: id,
                          graveId: graveId,
                          name: name,
                          birthDate: birthDate,
                          birthLocation: birthLocation,
                          deathDate: deathDate,
                          deathLocation: deathLocation,
                          marriageStatus: marriageStatus,
                          bio: bio)
        
        let graveRef = self.db.collection("grave")
        graveRef.document(String(grave.creatorId)).updateData(grave.dictionary){ err in
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

