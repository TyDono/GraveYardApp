//
//  NewGraveStoryTableViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 11/7/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class NewGraveStoryTableViewController: UITableViewController {
    
    @IBOutlet weak var storyTitleTextField: UITextField!
    @IBOutlet weak var storyBodyTextView: UITextView!
    
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
    
    func updateStoryData() {
        
        guard let graveId: String = MapViewController.shared.currentGraveId else { return }
        guard let storyId: String = graveStoryId else { return }
        guard let storyBody: String = storyBodyTextView.text else { return }
        guard let storyTitle: String = storyTitleTextField.text else { return }
        let storyImage: String = ""
        
        let story = Story(graveId: graveId,
                          storyId: storyId,
                          storyBody: storyBody,
                          storyTitle: storyTitle,
                          storyImage: storyImage)
        
        let storyRef = self.db.collection("grave")
        storyRef.document(String(story.graveId)).updateData(story.dictionary){ err in
            if let err = err {
                let alert1 = UIAlertController(title: "Not Saved", message: "Sorry, there was an error while trying to save your Story. Please try again.", preferredStyle: .alert)
                alert1.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert1.dismiss(animated: true, completion: nil)
                }))
                self.present(alert1, animated: true, completion: nil)
                print(err)
            } else {
                self.performSegue(withIdentifier: "editGraveStorySegue", sender: nil)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func saveStoryBarButtonTapped(_ sender: UIBarButtonItem) {
        updateStoryData()
    }
    
    
}
