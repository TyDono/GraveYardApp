//
//  AccountViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 7/8/20.
//  Copyright © 2020 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AccountViewController: UIViewController {

    @IBOutlet weak var dataCountLabel: UILabel!
    @IBOutlet weak var premiumStatusLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    
    // MARK: - Propeties
    
    var friendList: [String]?
    var friendRequests: [String]?
    var blockedList: [String]?
    var currentAuthID = Auth.auth().currentUser?.uid
    var db: Firestore!
    var dataCount: Double = 0.0
    var summer: String = "summer"
    var winter: String = "winter"
    var fall: String = "fall"
    var spring: String = "spring"
    var currentSeason: String?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        getUserData() //re-instate this when premium is out!!!!!!
//        self.premiumStatusLabel.text = "Premium accounts comming soon!"
//        self.dataCountLabel.text = "Limited time Only!!! Unlimited Data!!!"
        getCurrentSeason()
        changeBackground()
        
    }
    
    func getUserData() {
        guard let currentUserAuthID: String = self.currentAuthID else { return }
        let userRef = self.db.collection("userProfile").whereField("currentUserAuthId", isEqualTo: currentUserAuthID)
        userRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    if let dataCount = document.data()["dataCount"] as? Int,
                       let premiumStatus = document.data()["premiumStatus"] as? Int,
                       let userName = document.data()["userName"] as? String,
                       let friendList = document.data()["friendList"] as? Array<String>,
                       let friendRequests = document.data()["friendRequests"] as? Array<String>,
                       let blockedList = document.data()["blockedList"] as? Array<String> {
                        self.dataCount = Double(dataCount)
                        switch premiumStatus {
                        case 0:
                            self.premiumStatusLabel.text = "You are not currently subscribed to Remembrances Premium"
                        case 1:
                            self.premiumStatusLabel.text = "Your current subsciption is Tier 1"
                        case 2:
                            self.premiumStatusLabel.text = "Your current subsciption is Tier 2"
                        case 3:
                            self.premiumStatusLabel.text = "Your current subsciption is Tier 3"
                        default:
                            self.premiumStatusLabel.text = ""
                        }
                        self.userNameTextField.text = userName
                        self.friendList = friendList
                        self.friendRequests = friendRequests
                        self.blockedList = blockedList
                        
//                        if self.dataCount != 0.0 {
//                            let dividedDataCount: Double = self.dataCount/1000000.0
//                            let stringDataCount: String = String(dividedDataCount)
//                            self.dataCountLabel.text = "\(stringDataCount) mb / 5mb"
//                        } else {
//                            self.dataCountLabel.text = "0mb / 5mb"
//                        }
                    }
                }
            }
        }
    }
    
    func updateUserData() {
        db = Firestore.firestore()
        guard let userName = self.userNameTextField.text else {
            userNameTextField.isError(baseColor: UIColor.red.cgColor, numberOfShakes: 3, revert: true)
            return
        }
        guard let currentId = currentAuthID else { return }
        db.collection("userProfile").document(currentId).updateData([
            "dataCount": MyFirebase.currentDataUsage!,
            "userName": userName,
            "friendList": self.friendList ?? "",
            "friendRequests": self.friendRequests ?? "",
            "blockedList": self.blockedList ?? ""
        ]) { err in
            if let err = err {
                var alertStyle = UIAlertController.Style.alert
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    alertStyle = UIAlertController.Style.alert
                }
                let alertFailure = UIAlertController(title: "Account Not Saved", message: "Sorry, there was an error while trying to save your Accounte. Please try again.", preferredStyle: alertStyle)
                alertFailure.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alertFailure.dismiss(animated: true, completion: nil)
                }))
                self.present(alertFailure, animated: true, completion: nil)
                print("Error updating document: \(err)")
            } else {
                var alertStyle = UIAlertController.Style.alert
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    alertStyle = UIAlertController.Style.alert
                }
                let alertFailure = UIAlertController(title: "Account Saved!", message: "", preferredStyle: alertStyle)
                alertFailure.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alertFailure.dismiss(animated: true, completion: nil)
                }))
                self.present(alertFailure, animated: true, completion: nil)
                print("Document successfully updated")
            }
        }
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
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    @IBAction func saveAccountBarButtonTapped(_ sender: UIBarButtonItem) {
        self.updateUserData()
    }
    

}
