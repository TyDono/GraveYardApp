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

class PremiumViewController: UIViewController {

    @IBOutlet weak var dataCountLabel: UILabel!
    @IBOutlet weak var premiumStatusLabel: UILabel!
    
    // MARK: - Propeties
    
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
        //getUserData()// not rly used atm
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
                       let premiumStatus = document.data()["premiumStatus"] as? Int{
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
    
    // MARK: - Actions
    

}
