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
    @IBOutlet weak var friendListExpanderLabel: UILabel!
    @IBOutlet weak var friendRequestExpanderLabel: UILabel!
    @IBOutlet weak var ignoreListExpanderLabel: UILabel!
    @IBOutlet weak var tableViewFriendsLists: UITableView!
    @IBOutlet weak var tableViewFriendRequestList: UITableView!
    @IBOutlet weak var tableViewIgnoreList: UITableView!
    @IBOutlet weak var dataCountLabel: UILabel!
    @IBOutlet weak var premiumStatusLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    
    // MARK: - Propeties
    
    var friendUIDList: [String]? = []
    var friendNameList: [String]? = []
    
    var friendRequestsUIDList: [String]? = []
    var friendNameRequestsList: [String]? = []
    
    var ignoreUIDList: [String]? = []
    var ignoreNameList: [String]? = []
    
    var currentAuthID = Auth.auth().currentUser?.uid
    var db: Firestore!
    var dataCount: Double = 0.0
    var currentSeason: String?
    var premiumStatus: String = ""
    var userName: String = ""
    var friendListIsExpanded: Bool = false
    var friendRequestListIsExpanded: Bool = false
    var ignoreListIsExpanded: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewFriendsLists.delegate = self
        tableViewFriendsLists.dataSource = self
        tableViewFriendRequestList.delegate = self
        tableViewFriendRequestList.dataSource = self
        tableViewIgnoreList.delegate = self
        tableViewIgnoreList.dataSource = self
        db = Firestore.firestore()
        getUserData()
//        changeBackground()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return super.numberOfSections(in: tableView)
    }

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case tableViewFriendsLists:
            return self.friendNameList?.count ?? 0
        case tableViewFriendRequestList:
            return self.friendNameRequestsList?.count ?? 0
        case tableViewIgnoreList:
            return self.ignoreNameList?.count ?? 0
        default:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

            switch tableView {
            case tableViewFriendsLists:
//                let cell: FriendListDynamicTableViewCell = self.tableViewFriendsLists.dequeueReusableCell(withIdentifier: "friendListDynamicCell", for: indexPath) as! FriendListDynamicTableViewCell
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendListDynamicCell", for: indexPath) as? FriendListDynamicTableViewCell else { return UITableViewCell() }
//                cell.backgroundColor = UIColor.clear
//                cell.backgroundView = UIImageView.init(image: UIImage.init(named: "bookRed"))
                if let friends = friendNameList {
                    let friend = friends[indexPath.row]
                    cell.friendNameLabel.text = "\(friend)"
                    
                    let maskLayer = CAShapeLayer()
                    let bounds = cell.bounds
                    maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 7, width: bounds.width-4, height: bounds.height-4), cornerRadius: 5).cgPath
                    cell.layer.mask = maskLayer
                }
                if let friendsId = friendUIDList {
                    let friendId = friendsId[indexPath.row]
                    cell.friendId = friendId
                }
                return cell
                
            case tableViewFriendRequestList:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as? FriendRequestTableViewCell else { return UITableViewCell() }
//                cell.backgroundColor = UIColor.clear
//                cell.backgroundView = UIImageView.init(image: UIImage.init(named: "bookRed"))
                if let friendRequests = friendNameRequestsList {
                    let friendRequest = friendRequests[indexPath.row]
                    cell.friendRequestNameLabel.text = "\(friendRequest)"
                    
                    if let friendsRequestsId = friendRequestsUIDList {
                        let friendRequestId = friendsRequestsId[indexPath.row]
                        cell.friendRequestId = friendRequestId
                    }
                    
                    let maskLayer = CAShapeLayer()
                    let bounds = cell.bounds
                    maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 7, width: bounds.width-4, height: bounds.height-4), cornerRadius: 5).cgPath
                    cell.layer.mask = maskLayer
                }
                return cell
                
            case tableViewIgnoreList:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "IgnoreListCell", for: indexPath) as? IgnoreListTableViewCell else { return UITableViewCell() }
//                cell.backgroundColor = UIColor.clear
//                cell.backgroundView = UIImageView.init(image: UIImage.init(named: "bookRed"))
                if let ingores = ignoreNameList {
                    let ignore = ingores[indexPath.row]
                    cell.ignoreNameLabel.text = "\(ignore)"
                    
                    if let ignoresId = ignoreUIDList {
                        let ignoreId = ignoresId[indexPath.row]
                        cell.ignoreId = ignoreId
                    }
                    
                    let maskLayer = CAShapeLayer()
                    let bounds = cell.bounds
                    maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 7, width: bounds.width-4, height: bounds.height-4), cornerRadius: 5).cgPath
                    cell.layer.mask = maskLayer
                }
                return cell
            default:
                return super.tableView(tableView, cellForRowAt: indexPath)
            }

        
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToFriendsMemorials", let memorialsTVC = segue.destination as? MemorialsTableViewController {
            if let row = self.tableViewFriendsLists.indexPathForSelectedRow?.row, let friendMemorial = friendUIDList?[row] {
                memorialsTVC.currentAuthId = friendMemorial
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch tableView {
        case tableViewFriendsLists:
            performSegue(withIdentifier: "segueToFriendsMemorials", sender: nil)
        case tableViewFriendRequestList:
            var alertStyle = UIAlertController.Style.alert
            if (UIDevice.current.userInterfaceIdiom == .pad) {
              alertStyle = UIAlertController.Style.alert
            }
            let friendRequestAlert = UIAlertController(title: "Add this user to your Friends List?", message: "This will allow them to see all the memorials you have made and your private Memorials", preferredStyle: alertStyle)
            let dismiss = UIAlertAction(title: "Decline", style: .default, handler: nil)
            if let row = self.tableViewFriendRequestList.indexPathForSelectedRow?.row, let friendId = self.friendRequestsUIDList?[row], let friendRequestUserName = self.friendNameRequestsList?[row] {
                self.friendRequestsUIDList = self.friendRequestsUIDList?.filter(){$0 != friendId}
                self.friendNameRequestsList = self.friendNameRequestsList?.filter(){$0 != friendRequestUserName}
                self.tableView.reloadData()
                self.tableViewFriendRequestList.reloadData()
            }
            friendRequestAlert.addAction(dismiss)
            let goToLogIn = UIAlertAction(title: "Accept", style: .default, handler: { _ in
                if let row = self.tableViewFriendRequestList.indexPathForSelectedRow?.row, let friendRequestId = self.friendRequestsUIDList?[row], let friendRequestUserName = self.friendNameRequestsList?[row] {
                    self.friendRequestsUIDList = self.friendRequestsUIDList?.filter(){$0 != friendRequestId}
                    self.friendNameRequestsList = self.friendNameRequestsList?.filter(){$0 != friendRequestUserName}
                    self.friendUIDList?.append(friendRequestId)
                    self.tableView.reloadData()
                    self.tableViewFriendsLists.reloadData()
                    self.tableViewFriendRequestList.reloadData()
                }
            })
            friendRequestAlert.addAction(goToLogIn)
            self.present(friendRequestAlert, animated: true, completion: nil)
        case tableViewIgnoreList:
            var alertStyle = UIAlertController.Style.alert
            if (UIDevice.current.userInterfaceIdiom == .pad) {
              alertStyle = UIAlertController.Style.alert
            }
            let removeIgnoreAlert = UIAlertController(title: "Unblock this user?", message: "This will allow the user to once again send you friend requests", preferredStyle: alertStyle)
            let dismiss = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            removeIgnoreAlert.addAction(dismiss)
            let goToLogIn = UIAlertAction(title: "Unblock", style: .default, handler: { _ in
                if let row = self.tableViewIgnoreList.indexPathForSelectedRow?.row, let blockedUserId = self.ignoreUIDList?[row], let blockedUserName = self.ignoreNameList?[row] {
                    self.ignoreUIDList = self.ignoreUIDList?.filter(){$0 != blockedUserId }
                    self.ignoreNameList = self.ignoreNameList?.filter(){$0 != blockedUserName }
                    self.tableView.reloadData()
                    self.tableViewFriendRequestList.reloadData()
                }
            })
            removeIgnoreAlert.addAction(goToLogIn)
            self.present(removeIgnoreAlert, animated: true, completion: nil)
        default:
            switch (indexPath.section, indexPath.row) {
            case (1,1):
                switch friendListIsExpanded {
                case false:
                    friendListExpanderLabel.text = "Close Friend List"
                    friendListIsExpanded = true
                case true:
                    friendListExpanderLabel.text = "Open Friend List"
                    friendListIsExpanded = false
                }
                tableView.beginUpdates()
                tableView.endUpdates()
            case (2,1):
                switch friendRequestListIsExpanded {
                case false:
                    friendRequestExpanderLabel.text = "Close Friend Requests"
                    friendRequestListIsExpanded = true
                case true:
                    friendRequestExpanderLabel.text = "Open Friend Requests"
                    friendRequestListIsExpanded = false
                }
                tableView.beginUpdates()
                tableView.endUpdates()
            case (3,1):
                switch ignoreListIsExpanded {
                case false:
                    ignoreListExpanderLabel.text = "Close Ignore List"
                    ignoreListIsExpanded = true
                case true:
                    ignoreListExpanderLabel.text = "Open Ignore List"
                    ignoreListIsExpanded = false
                }
                tableView.beginUpdates()
                tableView.endUpdates()
            default:
                return
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            switch tableView {
            case tableViewFriendsLists:
                return 75
            case tableViewFriendRequestList:
                return 75
            case tableViewIgnoreList:
                return 75
            default:
                return 0
            }
        case (0,1):
            return 75
        case (0, 2):
            return 93
        case (1,0):
            return 0
        case (1,1):
            return 60
        case (1,2):
            switch friendListIsExpanded {
            case true:
                return 345
            case false:
                return 0
            }
        case (2,0):
            return 0
        case (2,1):
            return 60
        case (2,2):
            switch friendRequestListIsExpanded {
            case true:
                return 345
            case false:
                return 0
            }
        case (3,0):
            return 0
        case (3,1):
            return 60
        case(3,2):
            switch ignoreListIsExpanded {
            case true:
                return 345
            case false:
                return 0
            }
        default:
            return 100
        }
    }

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
                    if let premiumStatus = document.data()["premiumStatus"] as? Int,
                       let userName = document.data()["userName"] as? String,
                       let friendList = document.data()["friendList"] as? Array<String>,
                       let friendRequests = document.data()["friendRequests"] as? Array<String>,
                       let ignoredList = document.data()["ignoredList"] as? Array<String> {
                        //self.dataCount = Double(dataCount)
                        switch premiumStatus {
                        case 0:
                            self.premiumStatusLabel.text = "You are not currently subscribed to Remembrance's Premium"
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
                        self.ignoreUIDList = ignoredList
                        self.getFriendUserName()
                        self.getFriendRequestUserName()
                        self.getIgnoreUserName()
                        self.tableView.reloadData()
                        
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
        print(self.friendUIDList)
        guard let SafeFriendUIDList = self.friendUIDList else { return }
        for userName in SafeFriendUIDList  {
            let userRef = self.db.collection("userProfile").whereField("currentUserAuthId", isEqualTo: userName)
            userRef.getDocuments { (snapshot, error) in
                if error != nil {
                    print(error as Any)
                } else {
                    for document in (snapshot?.documents)! {
                        if let userName = document.data()["userName"] as? String {
                            print(userName)
                            self.friendNameList?.append(userName)
                            print(self.friendNameList)
                            self.tableView.reloadData()
                            self.tableViewFriendsLists.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func getFriendRequestUserName() {
        guard let SafeFriendRequestUIDList = self.friendRequestsUIDList else { return }
        for userName in SafeFriendRequestUIDList  {
            let userRef = self.db.collection("userProfile").whereField("currentUserAuthId", isEqualTo: userName)
            userRef.getDocuments { (snapshot, error) in
                if error != nil {
                    print(error as Any)
                } else {
                    for document in (snapshot?.documents)! {
                        if let userName = document.data()["userName"] as? String {
                            self.friendNameRequestsList?.append(userName)
                            self.tableView.reloadData()
                            self.tableViewFriendRequestList.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func getIgnoreUserName() {
        guard let SafeIgnoreUIDList = self.ignoreUIDList else { return }
        for userName in SafeIgnoreUIDList  {
            let userRef = self.db.collection("userProfile").whereField("currentUserAuthId", isEqualTo: userName)
            userRef.getDocuments { (snapshot, error) in
                if error != nil {
                    print(error as Any)
                } else {
                    for document in (snapshot?.documents)! {
                        if let userName = document.data()["userName"] as? String {
                            self.ignoreNameList?.append(userName)
                            self.tableView.reloadData()
                            self.tableViewIgnoreList.reloadData()
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
            "friendList": self.friendUIDList ?? "" ,
            "friendRequests": self.friendRequestsUIDList ?? "" ,
            "ignoredList": self.ignoreUIDList ?? ""
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
        self.tableViewIgnoreList.backgroundView = backgroundImage
    }
    
    // MARK: - Actions

    @IBAction func saveAccountBarButtonTapped(_ sender: UIBarButtonItem) {
        self.updateUserData()
    }
}


//class FriendListTableView: AccountTableViewController {
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        friendNameList?.count ?? 0
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as? FriendRequestTableViewCell else { return UITableViewCell() }
//        cell.backgroundColor = UIColor.clear
//        cell.backgroundView = UIImageView.init(image: UIImage.init(named: "bookRed"))
//        if let friendRequests = friendNameRequestsList {
//            let friendRequest = friendRequests[indexPath.row]
//            cell.friendRequestNameLabel.text = "\(friendRequest)"
//
//            if let friendsRequestsId = friendRequestsUIDList {
//                let friendRequestId = friendsRequestsId[indexPath.row]
//                cell.friendRequestId = friendRequestId
//            }
//
//            let maskLayer = CAShapeLayer()
//            let bounds = cell.bounds
//            maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 7, width: bounds.width-4, height: bounds.height-4), cornerRadius: 5).cgPath
//            cell.layer.mask = maskLayer
//        }
//        return cell
//    }
//
//}
