//
//  GraveStoryTableViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 11/7/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class GraveStoryTableViewController: UITableViewController {
    @IBOutlet weak var storyTitle: UILabel!
    @IBOutlet weak var storyBodyBio: UILabel!
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var graveStoryId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

}
