//
//  ProfileViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/16/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class GraveViewController: UIViewController {
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentUser: Grave?
  //  var userId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        getGraveData()
    }
    
    func getGraveData() {
        guard let uId: String = self.currentAuthID else { return }
        print("this is my uid i really like my uid \(uId)")
        let graveRef = self.db.collection("grave").whereField("id", isEqualTo: uId) //change this to the id that was tapped
        graveRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    if let id = document.data()["id"] as? String,
                        let name = document.data()["name"] as? String,
                        let birth = document.data()["birth"] as? String,
                        let death = document.data()["death"] as? String,
                        let bio = document.data()["bio"] as? String {
                        
                        self.nameLabel.text = name
                        self.birthLabel.text = birth
                        self.deathLabel.text = death
                        self.bioLabel.text = bio
                    }
                }
            }
        }
    }

}
