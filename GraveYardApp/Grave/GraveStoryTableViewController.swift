//
//  GraveStoryTableViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 11/7/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class GraveStoryTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    
    @IBOutlet weak var storyImagesScrollView: UIScrollView!
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
    let storage = Storage.storage()
    var graveStorytitleValue: String?
    var graveStoryBodyBioValue: String?
    var storyImagesArray: [UIImage?] = []
    var storyUIImage1: UIImage?
    var storyUIImage2: UIImage?
    var storyUIImage3: UIImage?
    var storyImageId1: String? = ""
    var storyImageId2: String? = ""
    var storyImageId3: String? = ""
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storyImagesScrollView.frame = view.frame
        chageTextColor()
        db = Firestore.firestore()
        storyTitle.text = graveStorytitleValue
        storyBodyBio.text = graveStoryBodyBioValue
        checkForCreatorId()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.getImage1()
            self.getImage2()
            self.getImage3()
        }

    }
    
    // MARK: - Functions
    
    func setUpScrollView() {
        for i in 0..<storyImagesArray.count {
            let imageView = UIImageView()
            imageView.image = storyImagesArray[i]
            let xPosition = self.view.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: self.storyImagesScrollView.frame.width, height: self.storyImagesScrollView.frame.height)
            storyImagesScrollView.contentSize.width = storyImagesScrollView.frame.width * CGFloat(i + 1)
            storyImagesScrollView.addSubview(imageView)
        }
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
        guard let currentAuthID = self.currentAuthID else {
            let reportGraveFailAlert = UIAlertController(title: "Failed to report", message: "You must be sign in to send a report", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
            reportGraveFailAlert.addAction(dismiss)
            self.present(reportGraveFailAlert, animated: true, completion: nil)
            return
        }
        let userReport = UserReport(reporterCreatorId: currentAuthID, reason: reportCommentsTextView.text, creatorId: creatorId!, graveId: "", storyId: graveStoryId!)
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

extension GraveStoryTableViewController {
    
    func getImage1() {
        if let imageStringId = self.storyImageId1 {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
                guard let data = data else {return}
                guard let image = UIImage(data: data) else {return}
//                self.storyImagesArray.append(image)
                self.storyUIImage1 = image
//                self.storyImage1.image = image // images exists but storyimage1 is nil
                guard let storyImage = self.storyUIImage1 else { return }
//                guard let storyImage: UIImage = self.storyImage1 else { return }
                self.storyImagesArray.append(storyImage)
                self.setUpScrollView()
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
                guard let data = data else {return}
                guard let image = UIImage(data: data) else {return}
                print(imageStringId)
                self.storyUIImage2 = image
//                self.storyImage2.image = image
                guard let storyImage = self.storyUIImage2 else { return }
//                self.storyImagesArray.append(image)
//                guard let storyImage: UIImage = self.storyImage2 else { return }
                self.storyImagesArray.append(storyImage)
                self.setUpScrollView()
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
                guard let data = data else {return}
                guard let image = UIImage(data: data) else {return}
                self.storyUIImage3 = image
//                self.storyImage3.image = image
                guard let storyImage = self.storyUIImage3 else { return }
//                self.storyImagesArray.append(image)
//                guard let storyImage: UIImage = self.storyImage3 else { return }
                self.storyImagesArray.append(storyImage)
                self.setUpScrollView()
            })
        } else {
            return
        }
    }
    
}
