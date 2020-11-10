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
import AVFoundation
import FirebaseAuth

class GraveStoriesTableViewController: UITableViewController {
    
    @IBOutlet weak var StoriesNavTitle: UINavigationItem!
    @IBOutlet weak var addStoryBarButton: UIBarButtonItem!
    
    // MARK: - Propeties
    
    var currentAuthID = Auth.auth().currentUser?.uid
    let storage = Storage.storage()
    var creatorId: String?
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
    var storyImageId6: String? = ""
    var currentGraveName: String = ""
    var currentGraveId: String?
    var bookSoundEffect: AVAudioPlayer?
//    var storyCount: Int = 0
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //chageTextColor()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        db = Firestore.firestore()
        print(currentGraveId)
        getGraveStories()
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        titleLabel.font = titleLabel.font.bold
        titleLabel.numberOfLines = 3
        titleLabel.textAlignment = .center
        titleLabel.text = "\(currentGraveName.uppercased()) STORIES"
        self.StoriesNavTitle.titleView = titleLabel
        changeBackground()
        if currentAuthID != creatorId {
            self.navigationItem.rightBarButtonItem = nil
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
        cell.backgroundView = UIImageView.init(image: UIImage.init(named: "bookRed"))
        
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
    
    // MARK: - Functions
    
    func chageTextColor() {
        tableView.separatorColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
    }
    
    func playBookSoundFile() {
        let path = Bundle.main.path(forResource: "paperBookSound.wav", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            bookSoundEffect = try AVAudioPlayer(contentsOf: url)
            bookSoundEffect?.play()
        } catch {
            print("couldn't load file")
        }
    }
    
    func getGraveStories() {
        var stories = [Story]()
        guard let currentGraveCreatorId: String = creatorId,
        let currentGraveId: String = self.currentGraveId else { return }
        print(currentGraveId)
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
        print(currentGraveId)
        guard let currentGrave = self.currentGraveId,
        GraveTableViewController.currentGraveStoryCount < 10 else {
            var alertStyle = UIAlertController.Style.alert
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                alertStyle = UIAlertController.Style.alert
            }
            let graveCreationFailAert = UIAlertController(title: "Too many Stories", message: "You are only allowed 10 stories per Memorial.", preferredStyle: alertStyle)
            let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
            graveCreationFailAert.addAction(dismiss)
            self.present(graveCreationFailAert, animated: true, completion: nil)
            return
        }
        guard let graveId: String = self.currentGraveId else { return }
        let storyId: String = UUID().uuidString
        let storyBody: String = ""
        let storyTitle: String = ""
        let storyImageId1: String = UUID().uuidString
        let storyImageId2: String = UUID().uuidString
        let storyImageId3: String = UUID().uuidString
        let storyImageId4: String = UUID().uuidString
        let storyImageId5: String = UUID().uuidString
        let storyImageId6: String = UUID().uuidString
        let storyImageArray: [String] = [storyImageId1, storyImageId2, storyImageId3, storyImageId4, storyImageId5, storyImageId6]
        currentGraveStoryId = storyId
        self.storyImageId1 = storyImageId1
        self.storyImageId2 = storyImageId2
        self.storyImageId3 = storyImageId3
        self.storyImageId4 = storyImageId4
        self.storyImageId5 = storyImageId5
        self.storyImageId6 = storyImageId6
        
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
                          storyImageId5: storyImageId5,
                          storyImageId6: storyImageId6)
        
        let storyRef = self.db.collection("stories")
        storyRef.document(String(story.storyId)).setData(story.dictionary) { err in
            if let err = err {
                var alertStyle = UIAlertController.Style.alert
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    alertStyle = UIAlertController.Style.alert
                }
                let graveCreationFailAert = UIAlertController(title: "Failed to create a Story", message: "Your device failed to properly create a Story, Please check your wifi and try again", preferredStyle: alertStyle)
                let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
                graveCreationFailAert.addAction(dismiss)
                self.present(graveCreationFailAert, animated: true, completion: nil)
                print(err)
            } else {
                GraveTableViewController.currentGraveStoryCount += 1
                self.db.collection("grave").document(currentGrave).updateData([
                    "storyCount": GraveTableViewController.currentGraveStoryCount
                ]) { err in
                    if let err = err {
                        GraveTableViewController.currentGraveStoryCount -= 1
                        print(err)
                        var alertStyle = UIAlertController.Style.alert
                        if (UIDevice.current.userInterfaceIdiom == .pad) {
                            alertStyle = UIAlertController.Style.alert
                        }
                        let graveCreationFailAert = UIAlertController(title: "Failed to create a Story", message: "Your device failed to properly create a Story, Please check your wifi and try again", preferredStyle: alertStyle)
                        let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
                        graveCreationFailAert.addAction(dismiss)
                        self.present(graveCreationFailAert, animated: true, completion: nil)
                        return
                    } else {
                        print("story count successfully updated")
                    }
                }
                self.performSegue(withIdentifier: "newGraveStorySegue", sender: nil)
                print("Added Data")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newGraveStorySegue", let newGraveStoryTVC = segue.destination as? NewGraveStoryTableViewController {
            newGraveStoryTVC.currentGraveId = currentGraveId
            newGraveStoryTVC.currentGraveStoryId = currentGraveStoryId
            newGraveStoryTVC.storyImageId1 = storyImageId1
            newGraveStoryTVC.storyImageId2 = storyImageId2
            newGraveStoryTVC.storyImageId3 = storyImageId3
            newGraveStoryTVC.storyImageId4 = storyImageId4
            newGraveStoryTVC.storyImageId5 = storyImageId5
            newGraveStoryTVC.storyImageId6 = storyImageId6
//            self.playBookSoundFile()
        } else if segue.identifier == "graveStorySegue", let graveStoryTVC = segue.destination as? GraveStoryTableViewController {
            if let row = self.tableView.indexPathForSelectedRow?.row, let story = stories?[row] {
                graveStoryTVC.currentGraveId = self.currentGraveId
                graveStoryTVC.graveStoryId = currentGraveStoryId
                graveStoryTVC.graveStorytitleValue = story.storyTitle
                graveStoryTVC.graveStoryBodyBioValue = story.storyBodyText
                graveStoryTVC.graveStoryId = story.storyId
                graveStoryTVC.creatorId = self.creatorId
                graveStoryTVC.storyImageId1 = story.storyImageId1
                graveStoryTVC.storyImageId2 = story.storyImageId2
                graveStoryTVC.storyImageId3 = story.storyImageId3
                graveStoryTVC.storyImageId4 = story.storyImageId4
                graveStoryTVC.storyImageId5 = story.storyImageId5
                graveStoryTVC.storyImageId6 = story.storyImageId6
//                self.playBookSoundFile()
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
    
    @IBAction func unwindtoGraveStories(_ sender: UIStoryboardSegue) {
        self.getGraveStories()
    }
    
}
