//
//  EditProfileViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/16/19.
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
    @IBOutlet weak var deathDatePicker: UIDatePicker!
    @IBOutlet weak var bioTextView: UITextView!
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentUser: Grave?
    var userId: String?
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        getGraveData()
    }
    
    func getGraveData() {
        guard let uId: String = self.currentAuthID else { return }
        print("this is my uid i really like my uid \(uId)")
        let graveRef = self.db.collection("grave").whereField("id", isEqualTo: uId)
        graveRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    if let name = document.data()["name"] as? String,
                        let birth = document.data()["birth"] as? Date,
                        let death = document.data()["death"] as? Date,
                        let bio = document.data()["bio"] as? String {
                        
                        self.nameTextField.text = name
                        self.birthDatePicker.date = birth
                        self.deathDatePicker.date = death
                        self.marriageStatusTextField.text = bio
                    }
                }
            }
        }
    }
    
    @IBAction func saveGraveInfoTapped(_ sender: UIBarButtonItem) {
        let id = currentAuthID!
        guard let name = nameTextField.text else { return }
        let birthDate = birthDatePicker.date
        let birth = formatter.string(from: birthDate)
        let deathDate = deathDatePicker.date
        let death = formatter.string(from: deathDate)
        guard let marriageStatus = marriageStatusTextField.text else { return }
        guard let bio = bioTextView.text else { return }
        
        let grave = Grave(id: id,
                          name: name,
                          birth: birth,
                          death: death,
                          marriageStatus: marriageStatus,
                          bio: bio)
        let graveRef = self.db.collection("grave")
        graveRef.document(String(grave.id)).updateData(grave.dictionary){ err in
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
