//
//  GraveTableViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/28/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn

class GraveTableViewController: UITableViewController {
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var graveMainImage: UIImageView!
    @IBOutlet weak var storiesButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var familyStatusLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var birthLocationLabel: UILabel!
    @IBOutlet weak var deathDateLabel: UILabel!
    @IBOutlet weak var deathLocationLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var graveNavTitle: UINavigationItem!
    @IBOutlet weak var pinQuoteLabel: UILabel!
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentUser: Grave?
    var grave: [Grave]?
    var graveId: String?
    var creatorId: String?
    var currentGraveId: String?
    var currentGraveLocation: String?
    var imageString: String?
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        chageTextColor()
        pinQuoteLabel.font = pinQuoteLabel.font.italic
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getGraveData()
    }
    
    func checkForCreatorId() {
        if currentAuthID == creatorId {
            rightBarButtonItem.title = "Edit"
        } else {
            rightBarButtonItem.title = "Report"
        }
    }
    
    func chageTextColor() {
        tableView.separatorColor = UIColor(0.0, 128.0, 128.0, 1.0)
        storiesButton.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor(0.0, 128.0, 128.0, 1.0)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }

    // MARK: - Table view data source

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "graveStoriesSegue", let graveStoriesTVC = segue.destination as? GraveStoriesTableViewController {
            graveStoriesTVC.graveStories = graveId
            graveStoriesTVC.creatorId = creatorId
        }
    }
    
    func getGraveData() {
        let graveRef = self.db.collection("grave").whereField("graveId", isEqualTo: MapViewController.shared.currentGraveId) //change this to the grave id that was tapped, NOT THE USER ID. THE USER ID IS FOR DIF STUFF. use String(arc4random_uniform(99999999)) to generate the grave Id when created
        graveRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    if let graveId = document.data()["graveId"] as? String,
                        let profileImageId = document.data()["profileImageId"] as? String,
                        let name = document.data()["name"] as? String,
                        let creatorId = document.data()["creatorId"] as? String,
                        let birthDate = document.data()["birthDate"] as? String,
                        let birthLocation = document.data()["birthLocation"] as? String,
                        let deathDate = document.data()["deathDate"] as? String,
                        let deathLocation = document.data()["deathLocation"] as? String,
                        let familyStatus = document.data()["familyStatus"] as? String,
                        let bio = document.data()["bio"] as? String,
                        let pinQuote = document.data()["pinQuote"] as? String {
                        print(name)
                        self.currentGraveId = graveId
                        self.imageString = profileImageId
                        self.graveNavTitle.title = "\(name)'s Headstone"
                        self.creatorId = creatorId
                        self.birthDateLabel.text = birthDate
                        self.birthLocationLabel.text = birthLocation
                        self.deathDateLabel.text = deathDate
                        self.deathLocationLabel.text = deathLocation
//                        self.familyStatusLabel.text = familyStatus
                        self.bioLabel.text = bio
                        self.pinQuoteLabel.text = "\"\(pinQuote)\""
                        if let currentUserId = self.currentAuthID {
                            if currentUserId != creatorId {
                                self.navigationItem.rightBarButtonItem?.title = "Report"
                            }
                        }
                        self.checkForCreatorId()
                        self.getImages()// always call last
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
    
    // MARK: - Actions
    
    @IBAction func editGraveBarButtonTapped(_ sender: UIBarButtonItem) {
        if currentAuthID == self.creatorId {
            performSegue(withIdentifier: "editGraveSegue", sender: nil)
        } else {
            performSegue(withIdentifier: "reportGraveSegue", sender: nil)
        }
    }
    
    @IBAction func storiesButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "graveStoriesSegue", sender: nil)
    }
    
    @IBAction func unwindToGrave(_ sender: UIStoryboardSegue) {}
    
}
