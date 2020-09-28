//
//  GraveTableViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/28/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn
import AVKit
import AVFoundation


class GraveTableViewController: UITableViewController {
    
    @IBOutlet weak var playVideoButton: UIButton!
    @IBOutlet weak var videoPreviewUIImage: UIImageView!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var graveMainImage: UIImageView!
    @IBOutlet weak var storiesButton: UIButton!
    @IBOutlet weak var familyStatusLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var birthLocationLabel: UILabel!
    @IBOutlet weak var deathDateLabel: UILabel!
    @IBOutlet weak var deathLocationLabel: UILabel!
    @IBOutlet weak var midTopLabel: UILabel!
    @IBOutlet weak var midBotLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var graveNavTitle: UINavigationItem!
    @IBOutlet weak var pinQuoteLabel: UILabel!
    @IBOutlet var reportPopOver: UIView!
    @IBOutlet weak var reportCommentsTextView: UITextView!
    @IBOutlet weak var videoCell: UITableViewCell!
    @IBOutlet weak var bioCell: UITableViewCell!
    
    // MARK: - Propeties
    
    static var currentGraveStoryCount: Int = 0
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentUser: Grave?
    var grave: [Grave]?
    var graveId: String?
    var creatorId: String?
    var currentGraveId: String? = MapViewController.shared.currentGraveId
    var currentGraveLocation: String?
    var imageString: String?
    var currentSeason: String?
    var videoURLString: String?
    var videoURL: URL?
    var currentGraveName: String = ""
    let storage = Storage.storage()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        self.reportPopOver.layer.cornerRadius = 10
        //chageTextColor()
        self.reportButton.layer.cornerRadius = 10
        pinQuoteLabel.font = pinQuoteLabel.font.italic
        self.storiesButton.layer.cornerRadius = 10
        self.playVideoButton.layer.cornerRadius = 10
//        changeBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getGraveData()
    }
    
    // MARK: - Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == self.view {
            self.removePopOverAnimate()
        }
    }
    
    func checkForCreatorId() {
        if currentAuthID == creatorId {
            rightBarButtonItem.title = "Edit"
            storiesButton.setTitle("Create/View Stories", for: .normal)
        } else {
            rightBarButtonItem.title = "Report"
            storiesButton.setTitle("View Stories", for: .normal)
        }
    }
    
    func videoPreviewImage() {
        guard let safeVideoURL = self.videoURL else { return }
        AVAsset(url: safeVideoURL).generateThumbnail { [weak self] (image) in
             DispatchQueue.main.async {
                guard let image = image else { return }
                self?.videoPreviewUIImage.image = image
                self!.tableView.reloadData()
             }
         }
    }
    
    func chageTextColor() {
        tableView.separatorColor = UIColor(0.0, 128.0, 128.0, 1.0)
        storiesButton.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor(0.0, 128.0, 128.0, 1.0)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    func changeBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "juhani-pelli-stone")
        backgroundImage.contentMode = UIView.ContentMode.scaleToFill
        self.tableView.backgroundView = backgroundImage
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
        let userReport = UserReport(reporterCreatorId: currentAuthID, reason: reportCommentsTextView.text, creatorId: creatorId!, graveId: currentGraveId!, storyId: "")
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
                self.removePopOverAnimate()
                self.present(graveReportAlertSucceed, animated: true, completion: nil)
            }
        }
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        tableView.rowHeight = UITableView.automaticDimension
////        switch (indexPath.section, indexPath.row) {
////        case (0, 0):
////            return 334
////        case (0, 1):
////            if self.videoURL == nil {
////                return 0
////            } else {
////                return 293
////            }
////        case (0, 2):
////            return 140
////        case (0, 3):
////            return 0
////        case (0, 4):
////            return UITableView.automaticDimension
////        case (_, _):
////            return 0
////        }
//        return tableView.rowHeight
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "graveStoriesSegue", let graveStoriesTVC = segue.destination as? GraveStoriesTableViewController {
            graveStoriesTVC.currentGraveId = currentGraveId
            graveStoriesTVC.graveStories = graveId
            graveStoriesTVC.creatorId = creatorId
            graveStoriesTVC.currentGraveName = currentGraveName
        } else if segue.identifier == "editGraveSegue", let editGraveTVC = segue.destination as? EditGraveTableViewController {
            editGraveTVC.currentGraveId = currentGraveId
        }
    }
    
    func getGraveData() {
        guard let safeCurrentGraveId = self.currentGraveId else { return }
        print(safeCurrentGraveId)
        let graveRef = self.db.collection("grave").whereField("graveId", isEqualTo: safeCurrentGraveId)
        graveRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    if let graveId = document.data()["graveId"] as? String,
                        let profileImageId = document.data()["profileImageId"] as? String,
                        let name = document.data()["name"] as? String,
                        let creatorId = document.data()["creatorId"] as? String,
                        let birthDate = document.data()["birthDate"] as? String,
                        let birthLocation = document.data()["birthLocation"] as? String,
                        let deathDate = document.data()["deathDate"] as? String,
                        let deathLocation = document.data()["deathLocation"] as? String,
//                        let familyStatus = document.data()["familyStatus"] as? String,
                        let bio = document.data()["bio"] as? String,
                        let pinQuote = document.data()["pinQuote"] as? String,
                        let videoURL = document.data()["videoURL"] as? String,
                        let storyCount = document.data()["storyCount"] as? Int,
                        let publicIsTrue = document.data()["publicIsTrue"] as? Bool {
                        if creatorId != MapViewController.shared.currentAuthID && publicIsTrue == false {
                            self.graveNavTitle.title = "PRIVATE"
                            self.midTopLabel.text = ""
                            self.midBotLabel.text = ""
                            self.birthDateLabel.text = ""
                            self.birthLocationLabel.text = ""
                            return
                        } else {
                            self.currentGraveId = graveId
                            self.imageString = profileImageId
                            let nameHeadstone = "\(name)"
                            self.graveNavTitle.title = nameHeadstone.uppercased()
                            self.creatorId = creatorId
                            if birthDate != "" {
                                self.midTopLabel.text = ""
                                self.midBotLabel.text = ""
                                self.birthDateLabel.text = birthDate
                                self.birthLocationLabel.text = birthLocation
                            } else {
                                self.birthDateLabel.text = ""
                                self.birthLocationLabel.text = ""
                                self.deathDateLabel.text = ""
                                self.deathLocationLabel.text = ""
                                self.midTopLabel.text = deathDate
                                self.midBotLabel.text = deathLocation
                            }
                            if deathDate != "" {
                                self.midTopLabel.text = ""
                                self.midBotLabel.text = ""
                                self.deathDateLabel.text = deathDate
                                self.deathLocationLabel.text = deathLocation
                            } else {
                                self.birthDateLabel.text = ""
                                self.birthLocationLabel.text = ""
                                self.deathDateLabel.text = ""
                                self.deathLocationLabel.text = ""
                                self.midTopLabel.text = birthDate
                                self.midBotLabel.text = birthLocation
                            }
//                            self.familyStatusLabel.text = familyStatus
                            self.bioLabel.text = bio
                            if self.bioLabel.text == nil {
                                self.bioCell.isHidden = true
                            }
                            if pinQuote == "" {
                                self.pinQuoteLabel.text = ""
                            } else {
                                self.pinQuoteLabel.text = "\"\(pinQuote)\""
                            }
                            if let currentUserId = self.currentAuthID {
                                if currentUserId != creatorId {
                                    self.navigationItem.rightBarButtonItem?.title = "Report"
                                }
                            }
                            GraveTableViewController.currentGraveStoryCount = storyCount
                            self.currentGraveName = name
                            self.videoURLString = videoURL
                            self.checkForCreatorId()
                            self.getVideo()
                            self.getImages()// always call last
                        }
                    }
                }
            }
        }
    }
    
    func getImages() {
        if let imageStringId = self.imageString {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("graveProfileImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (5000000), completion:  { (data, err) in
                guard let data = data else {
                    let clearedImage = UIImage(named: "default-avatar")
                    self.graveMainImage.image = clearedImage
                    return
                }
                guard let image = UIImage(data: data) else { return }
                self.graveMainImage.image = image
                self.tableView.reloadData()
            })
        } else {
            return
        }
    }
    
    func getVideo() {
        if let videoString = self.videoURLString {
            let storageRef = storage.reference()
            let graveProfileVideo = storageRef.child("graveProfileVideos/\(videoString)")
            graveProfileVideo.getData(maxSize: (100000000), completion:  { (data, err) in
//                guard let data = data else  { return }
                graveProfileVideo.downloadURL { (url, err) in
                    if let urlText = url {
                        self.videoURL = urlText
                        self.videoPreviewImage()
                    } else {
                        print(err as Any)
                    }
                }
            })
        }
    }
    
    func showPopOverAnimate() {
        self.reportPopOver.center = self.view.center
        self.reportPopOver.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.reportPopOver.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.reportPopOver.alpha = 1.0
            self.reportPopOver.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removePopOverAnimate() {
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
    
    func playURLVideo(url: URL) {
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player
        self.present(vc, animated: true) { vc.player?.play() }
    }
    
    // MARK: - Actions
    
    @IBAction func editGraveBarButtonTapped(_ sender: UIBarButtonItem) {
        if self.currentAuthID == self.creatorId {
            performSegue(withIdentifier: "editGraveSegue", sender: nil)
        } else {
            self.view.addSubview(reportPopOver)
            showPopOverAnimate()
           // reportPopOver.center = self.view.center
        }
    }
    
    @IBAction func storiesButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "graveStoriesSegue", sender: nil)
    }
    
    @IBAction func reportButtonTapped(_ sender: UIButton) {
        createReportData()
    }
    
    @IBAction func closePopUpButtonTapped(_ sender: UIButton) {
        removePopOverAnimate()
    }
    
    @IBAction func playVideo(_ sender: UIButton) {
        guard let safeVideoURLFromFirebase = self.videoURL else  { return }
        playURLVideo(url: safeVideoURLFromFirebase)
    }
    
    @IBAction func unwindToGrave(_ sender: UIStoryboardSegue) {}
    
}
