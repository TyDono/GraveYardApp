//
//  GraveViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/30/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class GraveViewController: UIViewController {
    @IBOutlet weak var graveMainImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var marriageStatusLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var birthLocationLabel: UILabel!
    @IBOutlet weak var deathDateLabel: UILabel!
    @IBOutlet weak var deathLocationLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentUser: Grave?
    var grave: [Grave]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        // changeBackground()
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
        let graveRef = self.db.collection("grave").whereField("id", isEqualTo: uId) //change this to the grave id that was tapped, NOT THE USER ID. THE USER ID IS FOR DIF STUFF. use String(arc4random_uniform(99999999)) to generate the grave Id when created
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
                        
                        self.nameLabel.text = name
                        self.marriageStatusLabel.text = marriageStatus
                        self.birthDateLabel.text = birthDate
                        self.birthLocationLabel.text = birthLocation
                        self.deathDateLabel.text = deathDate
                        self.deathLocationLabel.text = deathLocation
                        self.marriageStatusLabel.text = marriageStatus
                        self.bioLabel.text = bio
                    }
                }
            }
        }
    }
    
}

