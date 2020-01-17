//
//  GraveStoryTableViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 11/7/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase
import FirebaseAuth

class GraveStoryTableViewController: UITableViewController {
    @IBOutlet weak var storyTitle: UILabel!
    @IBOutlet weak var storyBodyBio: UILabel!
    
    // MARK: - Propeties
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var graveStoryId: String?
    var creatorId: String?
    var graveStorytitleValue: String?
    var graveStoryBodyBioValue: String?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chageTextColor()
        db = Firestore.firestore()
        storyTitle.text = graveStorytitleValue
        storyBodyBio.text = graveStoryBodyBioValue
        if currentAuthID != creatorId {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    // MARK: - Functions
    
    func chageTextColor() {
        tableView.separatorColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editGraveStorySegue", let editGraveStoryTVC = segue.destination as? NewGraveStoryTableViewController {
            editGraveStoryTVC.graveStoryId = graveStoryId
            editGraveStoryTVC.graveStoryTitleValue = storyBodyBio.text
            editGraveStoryTVC.graveStoryBodyTextValue = storyTitle.text
            editGraveStoryTVC
        }
    }
    
    // MARK: - Actions

    @IBAction func editStoryBarButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editGraveStorySegue", sender: nil)
    }
}
