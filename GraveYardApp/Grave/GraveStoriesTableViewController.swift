//
//  GraveStoriesTableViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/29/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase
import FirebaseAuth

class GraveStoriesTableViewController: UITableViewController {
    
    @IBOutlet weak var addStoryBarButton: UIBarButtonItem!
    
    var currentAuthID = Auth.auth().currentUser?.uid
    var creatorId: String?
    var graveStories: String?
    var db: Firestore!
    var tableArray = [String]()
    var stories: [Story]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getGraveStories()
        if currentAuthID != creatorId {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func getGraveStories() {
        var stories = [Story]()
        db.collection("stories").whereField("storyId", isEqualTo: currentAuthID!).getDocuments { (snapshot, error) in
                if error != nil {
                    print(Error.self)
                } else {
                    guard let snapshot = snapshot else {
                        print("could not unrwap snapshot")
                        return
                    }
                    for document in (snapshot.documents) {
                        if let storiesResult = document.data() as? [String: Any], let otherStories = Story.init(dictionary: storiesResult) {
                            stories.append(otherStories)
                        }
                        print("")
                    }
                    self.stories = stories
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    
    func createNewStory() {
        
        guard let graveId: String = MapViewController.shared.currentGraveId else { return }
        let storyId: String = UUID().uuidString
        let storyBody: String = ""
        let storyTitle: String = ""
        let storyImage: String = ""
        
        let story = Story(graveId: graveId,
                          storyId: storyId,
                          storyBody: storyBody,
                          storyTitle: storyTitle,
                          storyImage: storyImage)
        
        let storyRef = self.db.collection("grave")
        storyRef.document(String(story.storyId)).setData(story.dictionary) { err in
            if let err = err {
                let graveCreationFailAert = UIAlertController(title: "Failed to create a Story", message: "Your device failed to properly create a Story, Please check your wifi and try again", preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
                graveCreationFailAert.addAction(dismiss)
                self.present(graveCreationFailAert, animated: true, completion: nil)
                print(err)
            } else {
                self.performSegue(withIdentifier: "addGraveStorySegue", sender: nil)
                print("Added Data")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return stories?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "storyCell", for: indexPath) as? StoryTableViewCell else { return UITableViewCell() }

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.tableArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func addGraveStoryBarButtonTapped(_ sender: UIBarButtonItem) {
        createNewStory()
    }
    
}
