//
//  GraveStoriesTableViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/29/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class GraveStoriesTableViewController: UITableViewController {
    
    @IBOutlet weak var addStoryBarButton: UIBarButtonItem!
    
    // MARK: - Propeties
    
    var currentAuthID = Auth.auth().currentUser?.uid
    let storage = Storage.storage()
    var creatorId: String?
    var graveId: String? = MapViewController.shared.currentGraveId
    var graveStories: String?
    var db: Firestore!
    var tableArray = [String]()
    var stories: [Story]?
    var currentGraveStoryId: String?
    var currentStoryId: String?
    var storyImageId1: String? = ""
    var storyImageId2: String? = ""
    var storyImageId3: String? = ""
    var storyImageId4: String? = ""
    var storyImageId5: String? = ""
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //chageTextColor()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        db = Firestore.firestore()
//        getGraveStories()
        changeBackground()
        if currentAuthID != creatorId {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getGraveStories()
    }
    
    func chageTextColor() {
        tableView.separatorColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
    }
    
    func getGraveStories() {
        var stories = [Story]()
        guard let currentGraveCreatorId: String = creatorId else { return }
        guard let currentGraveId: String = graveId else { return }
        print(currentGraveCreatorId)
        db.collection("stories").whereField("graveId", isEqualTo: currentGraveId).getDocuments { (snapshot, error) in
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
        let storyImageArray: [String] = [String]()
        let storyImageId1: String = UUID().uuidString
        let storyImageId2: String = UUID().uuidString
        let storyImageId3: String = UUID().uuidString
        let storyImageId4: String = UUID().uuidString
        let storyImageId5: String = UUID().uuidString
        currentGraveStoryId = storyId
        self.storyImageId1 = storyImageId1
        self.storyImageId2 = storyImageId2
        self.storyImageId3 = storyImageId3
        self.storyImageId4 = storyImageId4
        self.storyImageId5 = storyImageId5
        
        let story = Story(creatorId: creatorId ?? "nul",
                          graveId: graveId,
                          storyId: storyId,
                          storyBodyText: storyBody,
                          storyTitle: storyTitle,
                          storyImageArray: storyImageArray,
                          storyImageId1: storyImageId1,
                          storyImageId2: storyImageId2,
                          storyImageId3: storyImageId3,
                          storyImageId4: storyImageId4,
                          storyImageId5: storyImageId5)
        
        let storyRef = self.db.collection("stories")
        storyRef.document(String(story.storyId)).setData(story.dictionary) { err in
            if let err = err {
                let graveCreationFailAert = UIAlertController(title: "Failed to create a Story", message: "Your device failed to properly create a Story, Please check your wifi and try again", preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
                graveCreationFailAert.addAction(dismiss)
                self.present(graveCreationFailAert, animated: true, completion: nil)
                print(err)
            } else {
                self.performSegue(withIdentifier: "newGraveStorySegue", sender: nil)
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
        cell.backgroundColor = UIColor.clear
        cell.backgroundView = UIImageView.init(image: UIImage.init(named: "bookBlue"))
        
        if let stories = stories {
            let story = stories[indexPath.row]
            cell.storyCellTitle.text = "\(story.storyTitle)"
            cell.cellStoryText = "\(story.storyBodyText)"
            let maskLayer = CAShapeLayer()
            let bounds = cell.bounds
            maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 2, y: 7, width: bounds.width-4, height: bounds.height-4), cornerRadius: 5).cgPath
            cell.layer.mask = maskLayer
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newGraveStorySegue", let newGraveStoryTVC = segue.destination as? NewGraveStoryTableViewController {
            newGraveStoryTVC.currentGraveStoryId = currentGraveStoryId
            newGraveStoryTVC.storyImageId1 = storyImageId1
            newGraveStoryTVC.storyImageId2 = storyImageId2
            newGraveStoryTVC.storyImageId3 = storyImageId3
        } else if segue.identifier == "graveStorySegue", let graveStoryTVC = segue.destination as? GraveStoryTableViewController {
            if let row = self.tableView.indexPathForSelectedRow?.row, let story = stories?[row] {
                graveStoryTVC.graveStoryId = currentGraveStoryId
                graveStoryTVC.graveStorytitleValue = story.storyTitle
                graveStoryTVC.graveStoryBodyBioValue = story.storyBodyText
                graveStoryTVC.graveStoryId = story.storyId
                graveStoryTVC.creatorId = self.creatorId
                graveStoryTVC.storyImageId1 = story.storyImageId1
                graveStoryTVC.storyImageId2 = story.storyImageId2
                graveStoryTVC.storyImageId3 = story.storyImageId3
            }
        }
    }
    
    func changeBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "bookshelf")
        backgroundImage.contentMode = UIView.ContentMode.scaleToFill
        self.tableView.backgroundView = backgroundImage
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "graveStorySegue", sender: self)
    }
    
    // MARK: - Action
    
    @IBAction func addGraveStoryBarButtonTapped(_ sender: UIBarButtonItem) {
        createNewStory()
    }
    
    @IBAction func unwindtoGraveStories(_ sender: UIStoryboardSegue) {}
    
}
