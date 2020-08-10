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
    
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet weak var leftArrowButton: UIButton!
    @IBOutlet weak var imageCounterLabel: UILabel!
    @IBOutlet weak var storyBodyTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var storyImagesScrollView: UIScrollView!
    @IBOutlet weak var storyTitle: UILabel!
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
    let screenHeight = UIScreen.main.bounds.height
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
        //chageTextColor()
        db = Firestore.firestore()
        storyTitle.text = graveStorytitleValue
        storyBodyTextView.text = graveStoryBodyBioValue
        checkForCreatorId()
        storyImagesScrollView.delegate = self
        self.reportButton.layer.cornerRadius = 10
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.31) {
            self.getImage1()
        }
        
    }
    
    // MARK: - Functions
    
    func changeImageLabelCounter() {
        switch storyImagesArray.count {
        case 0:
            self.imageCounterLabel.text = ""
            self.rightArrowButton.isHidden = true
            self.leftArrowButton.isHidden = true
        case 1:
            self.imageCounterLabel.text = ""
            self.rightArrowButton.isHidden = true
            self.leftArrowButton.isHidden = true
            
        case 2:
            switch storyImagesScrollView.contentOffset.x {
            case 0.0...112.0:
                self.imageCounterLabel.text = "1/2"
                self.leftArrowButton.isHidden = true
                self.rightArrowButton.isHidden = false
            case 113.0...414.0:
                self.imageCounterLabel.text = "2/2"
                self.rightArrowButton.isHidden = true
                self.leftArrowButton.isHidden = false
            default:
                self.imageCounterLabel.text = ""
            }
        case 3:
            switch storyImagesScrollView.contentOffset.x {
            case 0.0...112.0:
                self.imageCounterLabel.text = "1/3"
                self.leftArrowButton.isHidden = true
                self.rightArrowButton.isHidden = false
            case 113.0...614.0: // 414 is centered in
                self.imageCounterLabel.text = "2/3"
                self.rightArrowButton.isHidden = false
                self.leftArrowButton.isHidden = false
            case 613.0...828.0:
                self.imageCounterLabel.text = "3/3"
                self.rightArrowButton.isHidden = true
                self.leftArrowButton.isHidden = false
            default:
                self.imageCounterLabel.text = ""
            }
        default:
            self.imageCounterLabel.text = ""
        }
    }
    
    override func scrollViewDidScroll(_ storyImagesScrollView: UIScrollView) {
        changeImageLabelCounter()
    }
    
    func setUpScrollView() {
        for i in 0..<storyImagesArray.count {
            let imageView = UIImageView()
            imageView.image = storyImagesArray[i]
            let xPosition = self.view.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: self.storyImagesScrollView.frame.width, height: self.storyImagesScrollView.frame.height)
            imageView.contentMode = .scaleAspectFit
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
            editGraveStoryTVC.graveStoryBodyTextValue = storyBodyTextView.text
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
    
    @IBAction func leftArrowImageSlideButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func rightArrowImageSlideButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func unwindtoGraveStory(_ sender: UIStoryboardSegue) {}
    
}

extension GraveStoryTableViewController {
    //it's a mess :/  just placeholder for the tiem being due to time constraint
    func getImage1() {
        if let imageStringId = self.storyImageId1 {
            let storageRef1 = storage.reference()
            let graveProfileImage = storageRef1.child("storyImages/\(imageStringId)")
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
                self.changeImageLabelCounter()
                if let imageStringId = self.storyImageId2 {
                    let storageRef2 = self.storage.reference()
                    let graveProfileImage = storageRef2.child("storyImages/\(imageStringId)")
                    graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
                        guard let data = data else {return}
                        guard let image = UIImage(data: data) else {return}
                        print(imageStringId)
                        self.storyUIImage2 = image
                        guard let storyImage = self.storyUIImage2 else { return }
                        self.storyImagesArray.append(storyImage)
                        self.setUpScrollView()
                        self.changeImageLabelCounter()
                                if let imageStringId = self.storyImageId3 {
                                    let storageRef3 = self.storage.reference()
                            let graveProfileImage = storageRef3.child("storyImages/\(imageStringId)")
                            graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
                                guard let data = data else {return}
                                guard let image = UIImage(data: data) else {return}
                                self.storyUIImage3 = image
                                guard let storyImage = self.storyUIImage3 else { return }
                                self.storyImagesArray.append(storyImage)
                                self.setUpScrollView()
                                self.changeImageLabelCounter()
                            })
                        }
                    })
                }
            })
        } else {
                    if let imageStringId = self.storyImageId2 {
                let storageRef3 = storage.reference()
                let graveProfileImage = storageRef3.child("storyImages/\(imageStringId)")
                graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
                    guard let data = data else {return}
                    guard let image = UIImage(data: data) else {return}
                    print(imageStringId)
                    self.storyUIImage2 = image
                    guard let storyImage = self.storyUIImage2 else { return }
                    self.storyImagesArray.append(storyImage)
                    self.setUpScrollView()
                    self.changeImageLabelCounter()
                            if let imageStringId = self.storyImageId3 {
                                let storageRef = self.storage.reference()
                        let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
                        graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
                            guard let data = data else {return}
                            guard let image = UIImage(data: data) else {return}
                            self.storyUIImage3 = image
                            guard let storyImage = self.storyUIImage3 else { return }
                            self.storyImagesArray.append(storyImage)
                            self.setUpScrollView()
                            self.changeImageLabelCounter()
                        })
                    }
                })
            }
        }
    }
    
//    func getImage2() {
//        if let imageStringId = self.storyImageId2 {
//            let storageRef = storage.reference()
//            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
//            graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
//                guard let data = data else {return}
//                guard let image = UIImage(data: data) else {return}
//                print(imageStringId)
//                self.storyUIImage2 = image
//                guard let storyImage = self.storyUIImage2 else { return }
//                self.storyImagesArray.append(storyImage)
//                self.setUpScrollView()
//                self.changeImageLabelCounter()
//                self.getImage3()
//            })
//        } else {
//            self.getImage3()
//        }
//    }
//
//    func getImage3() {
//        if let imageStringId = self.storyImageId3 {
//            let storageRef = storage.reference()
//            let graveProfileImage = storageRef.child("storyImages/\(imageStringId)")
//            graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
//                guard let data = data else {return}
//                guard let image = UIImage(data: data) else {return}
//                self.storyUIImage3 = image
//                guard let storyImage = self.storyUIImage3 else { return }
//                self.storyImagesArray.append(storyImage)
//                self.setUpScrollView()
//                self.changeImageLabelCounter()
//            })
//        } else {
//            return
//        }
//    }
    
}
