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
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentUser: Grave?
    var userId: String?

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
                        let birth = document.data()["birth"] as? String,
                        let death = document.data()["death"] as? String,
                        let bio = document.data()["bio"] as? String {
                        
                        self.nameTextField.text = name
                        self.birthTextField.text = birth
                        self.deathTextField.text = death
                        self.bioTextField.text = bio
                    }
                }
            }
        }
    }
    
    @IBAction func saveGraveInfoTapped(_ sender: UIBarButtonItem) {
        guard let id = currentAuthID!
        guard let name = nameTextField.text else { return }
        guard let birth = birthTextField.text else { return }
        guard let death = deathSizeTextField.text else  { return }
        guard let bio = bioTextField.text else  { return }
        
        let grave = Grave(id: id,
                          name: name,
                          birth: birth,
                          death: death,
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
