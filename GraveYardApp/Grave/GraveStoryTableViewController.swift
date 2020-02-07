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
    var storyImageArray: [String]?
    
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
    }
    
    // MARK: - Functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyImageArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    func chageTextColor() {
        tableView.separatorColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editGraveStorySegue", let editGraveStoryTVC = segue.destination as? NewGraveStoryTableViewController {
            editGraveStoryTVC.graveStoryId = graveStoryId
            editGraveStoryTVC.graveStoryTitleValue = storyBodyBio.text
            editGraveStoryTVC.graveStoryBodyTextValue = storyTitle.text
            editGraveStoryTVC
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
