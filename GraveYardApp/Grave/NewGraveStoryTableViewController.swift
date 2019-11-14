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
        chageTextColor()
        db = Firestore.firestore()
    }
    
    func chageTextColor() {
        navigationItem.leftBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
    }
    
    func updateStoryData() {
        
        guard let creatorId: String = currentAuthID else { return }
        guard let graveId: String = MapViewController.shared.currentGraveId else { return }
        guard let storyId: String = graveStoryId else { return }
        guard let storyBodyText: String = storyBodyTextView.text else { return }
        guard let storyTitle: String = storyTitleTextField.text else { return }
        let storyImage: String = ""
        
        let story = Story(creatorId: creatorId,
                          graveId: graveId,
                          storyId: storyId,
                          storyBodyText: storyBodyText,
                          storyTitle: storyTitle,
                          storyImage: storyImage)
        
        let storyRef = self.db.collection("stories")
        storyRef.document(String(story.storyId)).updateData(story.dictionary){ err in
            if let err = err {
                let alert1 = UIAlertController(title: "Not Saved", message: "Sorry, there was an error while trying to save your Story. Please try again.", preferredStyle: .alert)
                alert1.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert1.dismiss(animated: true, completion: nil)
                }))
                self.present(alert1, animated: true, completion: nil)
                print(err)
            } else {
                self.performSegue(withIdentifier: "unwindtoGraveStoriesSegue", sender: nil)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func saveStoryBarButtonTapped(_ sender: UIBarButtonItem) {
        updateStoryData()
    }
    
    
}
