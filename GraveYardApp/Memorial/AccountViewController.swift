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
    
    // MARK: - Propeties
    
    var currentAuthID = Auth.auth().currentUser?.uid
    var db: Firestore!
    var dataCount: Int = 0
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
        self.premiumStatusLabel.text = "Premium accounts comming soon!"
        self.dataCountLabel.text = "Limited time Only!!! Unlimited Data!!!"
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
                    if let dataCount = document.data()["dataCount"] as? Int {
                        self.dataCount = dataCount
                        if dataCount != 0 {
                            let dividedDataCount: Int = self.dataCount/1000
                            let stringDataCount: String = String(dividedDataCount)
                            self.dataCountLabel.text = "\(stringDataCount) kb / 5,000 kb"
                        } else {
                            self.dataCountLabel.text = "0 kb / 5,000 kb"
                        }
                    }
                }
            }
        }
    }
    
    func updateUserData() {
        db = Firestore.firestore()
        guard let currentId = currentAuthID else { return }
        db.collection("userProfile").document(currentId).updateData([
            "dataCount": MyFirebase.currentDataUsage!
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
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

}
