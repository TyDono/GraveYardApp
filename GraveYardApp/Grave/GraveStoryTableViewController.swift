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

class GraveStoryTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var storyTitle: UILabel!
    @IBOutlet weak var storyBodyBio: UILabel!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    @IBOutlet var reportPopOver: UIView!
    @IBOutlet weak var reportCommentsTextView: UITextView!
    
    // MARK: - Propeties
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var graveStoryId: String?
    var creatorId: String?
    var graveStorytitleValue: String?
    var graveStoryBodyBioValue: String?
    var storyImageArray: [UIImage]?
    var storyImageId1: String = ""
    var storyImageId2: String = ""
    var storyImageId3: String = ""
    
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
<<<<<<< HEAD
        getImage1()
        getImage2()
        getImage3()
=======
>>>>>>> parent of 69dd09b... images are pulled down, still trying to get them into the array
    }
    
    // MARK: - Functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyImageArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryImagesCell", for: indexPath) as! StoryImagesCollectionViewCell
        cell.storyImages.image = self.storyImageArray?[indexPath.row]//make array of images
        
        return cell
    }
    
    func chageTextColor() {
        tableView.separatorColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editGraveStorySegue", let editGraveStoryTVC = segue.destination as? NewGraveStoryTableViewController {
            editGraveStoryTVC.currentGraveStoryId = graveStoryId
            editGraveStoryTVC.graveStoryTitleValue = storyTitle.text
            editGraveStoryTVC.graveStoryBodyTextValue = storyBodyBio.text
            editGraveStoryTVC.storyImageId1 = self.storyImageId1
            editGraveStoryTVC.storyImageId2 = self.storyImageId2
            editGraveStoryTVC.storyImageId3 = self.storyImageId3
        }
    }
    
    func createReportData() {
        let userReportId: String = UUID().uuidString
        let userReport = UserReport(reporterCreatorId: currentAuthID ?? "No Creator ID", reason: reportCommentsTextView.text, creatorId: creatorId!, graveId: "", storyId: graveStoryId!)
        let userReportRef = self.db.collection("userReports")
        userReportRef.document(userReportId).setData(userReport.dictionary) { err in
            if let err = err {
                let reportGraveFailAlert = UIAlertController(title: "Failed to report", message: "Your device failed to send the report. Please make sure you are logged in with an internet connection.", preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
                reportGraveFailAlert.addAction(dismiss)
                self.present(reportGraveFailAlert, animated: true, completion: nil)
                print(err)
            } else {
                let graveReportAlertSucceed = UIAlertController(title: "Thank you!", message: "Your report has been received, thank you for your help.", preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
                graveReportAlertSucceed.addAction(dismiss)
                self.removeReportPopOverAnimate()
                self.present(graveReportAlertSucceed, animated: true, completion: nil)
            }
        }
    }
    
    func checkForCreatorId() {
        if currentAuthID == creatorId {
            rightBarButtonItem.title = "Edit"
        } else {
            rightBarButtonItem.title = "Report"
        }
    }
    
    func showReportPopOverAnimate() {
        self.reportPopOver.center = self.view.center
        self.reportPopOver.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.reportPopOver.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.reportPopOver.alpha = 1.0
            self.reportPopOver.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeReportPopOverAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.reportPopOver.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.reportPopOver.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.reportPopOver.removeFromSuperview()
                }
        });
    }
    
    // MARK: - Actions
    
    @IBAction func reportButtonTapped(_ sender: UIButton) {
        createReportData()
    }
    
    @IBAction func closeReportPopUp(_ sender: UIButton) {
        removeReportPopOverAnimate()
    }
    
    @IBAction func editStoryBarButtonTapped(_ sender: UIBarButtonItem) {
        if currentAuthID == self.creatorId {
            performSegue(withIdentifier: "editGraveStorySegue", sender: nil)
        } else {
            self.view.addSubview(reportPopOver)
            showReportPopOverAnimate()
        }
    }
}
<<<<<<< HEAD

extension GraveStoryTableViewController {
    
    func getImage1() {
        if let imageStringId = self.storyImageId1 {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
                guard let data = data else { return }
                guard let image = UIImage(data: data) else { return }
                self.storyImagesArray.append(image)
                self.storyImage1.image = image // images exists but storyimage1 is nil
//                guard let storyImage = self.storyImage1.image else { return }
                self.storyImagesArray.append(image)
//                guard let storyImage: UIImage = self.storyImage1 else { return }
            })
        } else {
            return
        }
    }
    
    func getImage2() {
        if let imageStringId = self.storyImageId2 {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
                guard let data = data else { return }
                guard let image = UIImage(data: data) else { return }
                self.storyImage2.image = image
//                guard let storyImage = self.storyImage2.image else { return }
                self.storyImagesArray.append(image)
//                guard let storyImage: UIImage = self.storyImage2 else { return }
//                self.storyImagesArray?.append(storyImage)
            })
        } else {
            return
        }
    }
    
    func getImage3() {
        if let imageStringId = self.storyImageId3 {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
                guard let data = data else { return }
                guard let image = UIImage(data: data) else { return }
                self.storyImage3.image = image
//                guard let storyImage = self.storyImage3.image else { return }
                self.storyImagesArray.append(image)
//                guard let storyImage: UIImage = self.storyImage3 else { return }
                
            })
        } else {
            return
        }
    }
    
}
=======
>>>>>>> parent of 69dd09b... images are pulled down, still trying to get them into the array
