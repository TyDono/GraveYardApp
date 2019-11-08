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
        if currentAuthID != creatorId {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func getGraveStories() {
        var stories = [Story]()
        db.collection("stories").whereField("storyId", isEqualTo: graveStories!).getDocuments { (snapshot, error) in
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
    
    @IBAction func addGraveStoryBarButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "graveStorySegue", sender: nil)
    }
    
}
