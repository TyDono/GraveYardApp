//
//  AccountTableViewController.swift
//  Remembrances
//
//  Created by Tyler Donohue on 10/6/20.
//  Copyright © 2020 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AccountTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet var tableViewMain: UITableView!
    @IBOutlet weak var tableViewFriendsLists: UITableView!
    @IBOutlet weak var tableViewFriendRequestList: UITableView!
    @IBOutlet weak var tableViewFriendIgnoreListList: UITableView!
    @IBOutlet weak var dataCountLabel: UILabel!
    @IBOutlet weak var premiumStatusLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    
    // MARK: - Propeties
    
    var friendUIDList: [String]?
    var friendList: [String]?
    
    var friendRequestsUIDList: [String]?
    var friendRequestsList: [String]?
    
    var ignoreUIDList: [String]?
    var ignoreList: [String]?
    
    var currentAuthID = Auth.auth().currentUser?.uid
    var db: Firestore!
    var dataCount: Double = 0.0
    var currentSeason: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        //getUserData() //We don't need user data atm.
        changeBackground()
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
        case tableViewFriendsLists:
            return self.friendList?.count ?? 0
        case tableViewFriendRequestList:
            return self.friendRequestsList?.count ?? 0
        case tableViewFriendIgnoreListList:
            return self.ignoreList?.count ?? 0
        default:
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView {
        
        case tableViewFriendsLists:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsListCell", for: indexPath) as? FriendsListTableViewCell else { return UITableViewCell() }
            if let friends = friendList {
                let friend = friends[indexPath.row]
                cell.friendNameLabel.text = "\(friend)"
            }
            return cell
            
        case tableViewFriendRequestList:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as? FriendRequestTableViewCell else { return UITableViewCell() }
            if let friendRequests = friendRequestsList {
                let friendRequest = friendRequests[indexPath.row]
                cell.friendRequestNameLabel.text = "\(friendRequest)"
            }
            return cell
            
        case tableViewFriendIgnoreListList:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "IgnoreListCell", for: indexPath) as? IgnoreListTableViewCell else { return UITableViewCell() }
            if let ingores = ignoreList {
                let ignore = ingores[indexPath.row]
                cell.ignoreNameLabel.text = "\(ignore)"
            }
            return cell
        case tableViewMain:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PremiumStatusCell", for: indexPath) as? AccountTableViewCell else { return UITableViewCell() }
            return UITableViewCell()
            
        default:
            return UITableViewCell()
        }
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    
    // MARK: - Functions
    
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
                        self.friendUIDList = friendList
                        self.friendRequestsUIDList = friendRequests
                        self.ignoreUIDList = blockedList
                        self.getFriendUserName()
                        self.getFriendRequestUserName()
                        self.getIgnoreUserName()
                        
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
    
    func getFriendUserName() {
        guard let SafeFriendUIDList = self.friendUIDList else { return }
        for userName in SafeFriendUIDList  {
            let userRef = self.db.collection("userProfile").whereField("userName", isEqualTo: userName)
            userRef.getDocuments { (snapshot, error) in
                if error != nil {
                    print(error as Any)
                } else {
                    for document in (snapshot?.documents)! {
                        if let userName = document.data()["userName"] as? String {
                            self.friendList?.append(userName)
                        }
                    }
                }
            }
        }
    }
    
    func getFriendRequestUserName() {
        guard let SafeFriendRequestUIDList = self.friendRequestsUIDList else { return }
        for userName in SafeFriendRequestUIDList  {
            let userRef = self.db.collection("userProfile").whereField("userName", isEqualTo: userName)
            userRef.getDocuments { (snapshot, error) in
                if error != nil {
                    print(error as Any)
                } else {
                    for document in (snapshot?.documents)! {
                        if let userName = document.data()["userName"] as? String {
                            self.friendRequestsUIDList?.append(userName)
                        }
                    }
                }
            }
        }
    }
    
    func getIgnoreUserName() {
        guard let SafeIgnoreUIDList = self.ignoreUIDList else { return }
        for userName in SafeIgnoreUIDList  {
            let userRef = self.db.collection("userProfile").whereField("userName", isEqualTo: userName)
            userRef.getDocuments { (snapshot, error) in
                if error != nil {
                    print(error as Any)
                } else {
                    for document in (snapshot?.documents)! {
                        if let userName = document.data()["userName"] as? String {
                            self.ignoreList?.append(userName)
                        }
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
            "friendRequests": self.friendRequestsList ?? "",
            "blockedList": self.ignoreList ?? ""
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
    
    func changeBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "bookshelf")
        backgroundImage.contentMode = UIView.ContentMode.scaleToFill
        self.tableViewFriendsLists.backgroundView = backgroundImage
        self.tableViewFriendRequestList.backgroundView = backgroundImage
        self.tableViewFriendIgnoreListList.backgroundView = backgroundImage
    }
    
    // MARK: - Actions

    @IBAction func saveAccountBarButtonTapped(_ sender: UIBarButtonItem) {
        self.updateUserData()
    }
}
