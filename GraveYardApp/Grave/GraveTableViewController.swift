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
    
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var headstoneBasicInfoImage: UIImageView!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var graveMainImage: UIImageView!
    @IBOutlet weak var storiesButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var familyStatusLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var birthLocationLabel: UILabel!
    @IBOutlet weak var deathDateLabel: UILabel!
    @IBOutlet weak var deathLocationLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var graveNavTitle: UINavigationItem!
    @IBOutlet weak var pinQuoteLabel: UILabel!
    @IBOutlet var reportPopOver: UIView!
    @IBOutlet weak var reportCommentsTextView: UITextView!
    @IBOutlet weak var videoCell: UITableViewCell!
    @IBOutlet weak var bioCell: UITableViewCell!
    
    // MARK: - Propeties
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentUser: Grave?
    var grave: [Grave]?
    var graveId: String?
    var creatorId: String?
    var currentGraveId: String?
    var currentGraveLocation: String?
    var imageString: String?
    var summer: String = "summer"
    var winter: String = "winter"
    var fall: String = "fall"
    var spring: String = "spring"
    var currentSeason: String?
    let storage = Storage.storage()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        self.reportPopOver.layer.cornerRadius = 10
        //chageTextColor()
        checkForBioLabel()
        self.reportButton.layer.cornerRadius = 10
        pinQuoteLabel.font = pinQuoteLabel.font.italic
        self.storiesButton.layer.cornerRadius = 10
//        getCurrentSeason()
//        changeBackground()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        getGraveData()
    }
    
    // MARK: - Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("lets go")
         let touch = touches.first
         if touch?.view == self.view {
            print("pablo hestiastes")
            self.removePopOverAnimate()
        }
        print("diamante")
    }
    
    func checkForCreatorId() {
        if currentAuthID == creatorId {
            rightBarButtonItem.title = "Edit"
        } else {
            rightBarButtonItem.title = "Report"
        }
    }
    
    func checkForBioLabel() {
        if self.bioLabel.text == nil {
            self.bioCell.isHidden = true
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
    
    func getCurrentSeason() {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "MM"
        let formattedDate = format.string(from: date)
        switch formattedDate {
        case "01":
            self.currentSeason = self.winter
        case "02":
            self.currentSeason = self.winter
        case "03":
            self.currentSeason = self.spring
        case "04":
            self.currentSeason = self.spring
        case "05":
            self.currentSeason = self.spring
        case "06":
            self.currentSeason = self.summer
        case "07":
            self.currentSeason = self.summer
        case "08":
            self.currentSeason = self.summer
        case "09":
            self.currentSeason = self.fall
        case "10":
            self.currentSeason = self.fall
        case "11":
            self.currentSeason = self.fall
        case "12":
            self.currentSeason = self.winter
        default:
            self.currentSeason = self.summer
        }
    }
    
    func changeBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: currentSeason ?? "summer")
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "graveStoriesSegue", let graveStoriesTVC = segue.destination as? GraveStoriesTableViewController {
            graveStoriesTVC.graveStories = graveId
            graveStoriesTVC.creatorId = creatorId
        }
    }
    
    func getGraveData() {
        let graveRef = self.db.collection("grave").whereField("graveId", isEqualTo: MapViewController.shared.currentGraveId!) //change this to the grave id that was tapped, NOT THE USER ID. THE USER ID IS FOR DIF STUFF. use String(arc4random_uniform(99999999)) to generate the grave Id when created
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
                        let familyStatus = document.data()["familyStatus"] as? String,
                        let bio = document.data()["bio"] as? String,
                        let pinQuote = document.data()["pinQuote"] as? String {
                        print(name)
                        self.currentGraveId = graveId
                        self.imageString = profileImageId
                        let nameHeadstone = "\(name)'s Headstone"
                        self.graveNavTitle.title = nameHeadstone.uppercased()
                        self.creatorId = creatorId
                        self.birthDateLabel.text = birthDate
                        self.birthLocationLabel.text = birthLocation
                        self.deathDateLabel.text = deathDate
                        self.deathLocationLabel.text = deathLocation
                        self.familyStatusLabel.text = familyStatus
                        self.bioLabel.text = bio
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
                        self.checkForCreatorId()
                        self.getImages()// always call last
                    }
                }
            }
        }
    }
    
    func getImages() {
        if let imageStringId = self.imageString {
            let storageRef = storage.reference()
            let graveProfileImage = storageRef.child("graveProfileImages/\(imageStringId)")
            graveProfileImage.getData(maxSize: (1024 * 1024), completion:  { (data, err) in
                guard let data = data else {return}
                guard let image = UIImage(data: data) else {return}
                self.graveMainImage.image = image
            })
        } else {
            return
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
    
    // MARK: - Actions
    
    @IBAction func editGraveBarButtonTapped(_ sender: UIBarButtonItem) {
        if currentAuthID == self.creatorId {
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
    
    @IBAction func unwindToGrave(_ sender: UIStoryboardSegue) {}
    
}
