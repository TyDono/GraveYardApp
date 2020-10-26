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
    @IBOutlet weak var tableViewFriendList: UITableView!
    @IBOutlet weak var tableViewFriendRequestList: UITableView!
    @IBOutlet weak var tableViewIgnoreList: UITableView!
    @IBOutlet weak var dataCountLabel: UILabel!
    @IBOutlet weak var premiumStatusLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    
    // MARK: - Propeties
    
    var friendIdList: [String]? = []
    var friendNameList: [String]? = []
    
    var friendRequestsIdList: [String]? = []
    var friendNameRequestList: [String]? = []
    
    var ignoreIdList: [String]? = []
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
    var toBeRemovedFriendIdList: [String]? = [] // when you removed a friend this var wil be used to make sure they also have your removed
    var toBeRemovedFriendNameList: [String]? = []
    var friendIdListToBeAdded: [String]? = []
    var friendNameListToBeAdded: [String]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewFriendList.delegate = self
        tableViewFriendList.dataSource = self
        tableViewFriendRequestList.delegate = self
        tableViewFriendRequestList.dataSource = self
        tableViewIgnoreList.delegate = self
        tableViewIgnoreList.dataSource = self
        db = Firestore.firestore()
        userNameTextField.setBottomBorderOnlyWith(color: UIColor.gray.cgColor)
        getUserData()
        //        changeBackground()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == tableViewMain {
            return super.numberOfSections(in: tableView)
        } else {
            return 1
        }
    }
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        return 1
    //    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case tableViewFriendList:
            return self.friendNameList?.count ?? 0
        case tableViewFriendRequestList:
            print(friendNameRequestList?.count)
            return self.friendNameRequestList?.count ?? 0
        case tableViewIgnoreList:
            return self.ignoreNameList?.count ?? 0
        default:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case tableViewFriendList:
            switch indexPath.section {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendListDynamicCell", for: indexPath) as? FriendListDynamicTableViewCell else { return UITableViewCell() }
                //                cell.backgroundColor = UIColor.clear
                //                cell.backgroundView = UIImageView.init(image: UIImage.init(named: "bookRed"))
                if let friends = friendNameList, let friendsId = friendIdList {

                    let friendId = friendsId[indexPath.row]
                    print(friendId)
                    cell.friendId = friendId
                    let friendName = friends[indexPath.row]
                    print(friendName)
                    cell.friendNameLabel.text = "\(friendName)"
                    
                    let maskLayer = CAShapeLayer()
                    let bounds = cell.bounds
                    maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 7, width: bounds.width-4, height: bounds.height-4), cornerRadius: 5).cgPath
                    cell.layer.mask = maskLayer
                }
                return cell
            default:
                return UITableViewCell()
            }
            
        case tableViewFriendRequestList:
            switch indexPath.section {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as? FriendRequestTableViewCell else { return UITableViewCell() }
                //                cell.backgroundColor = UIColor.clear
                //                cell.backgroundView = UIImageView.init(image: UIImage.init(named: "bookRed"))
                if let friendRequests = friendNameRequestList, let friendsRequestsId = friendRequestsIdList {
                    let friendRequestName = friendRequests[indexPath.row]
                    cell.friendRequestNameLabel.text = "\(friendRequestName)"
                    let friendRequestId = friendsRequestsId[indexPath.row]
                    cell.friendRequestId = friendRequestId
                    
                    let maskLayer = CAShapeLayer()
                    let bounds = cell.bounds
                    maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 7, width: bounds.width-4, height: bounds.height-4), cornerRadius: 5).cgPath
                    cell.layer.mask = maskLayer
                }
                return cell
            default:
                return UITableViewCell()
            }
            
        case tableViewIgnoreList:
            switch indexPath.section {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "IgnoreListCell", for: indexPath) as? IgnoreListTableViewCell else { return UITableViewCell() }
                //                cell.backgroundColor = UIColor.clear
                //                cell.backgroundView = UIImageView.init(image: UIImage.init(named: "bookRed"))
                if let ingores = ignoreNameList, let ignoresId = ignoreIdList {
                    let ignore = ingores[indexPath.row]
                    cell.ignoreNameLabel.text = "\(ignore)"
                    let ignoreId = ignoresId[indexPath.row]
                    cell.ignoreId = ignoreId
                    
                    let maskLayer = CAShapeLayer()
                    let bounds = cell.bounds
                    maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 7, width: bounds.width-4, height: bounds.height-4), cornerRadius: 5).cgPath
                    cell.layer.mask = maskLayer
                }
                return cell
            default:
                return UITableViewCell()
            }
            
        default:
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case tableViewFriendList:
            performSegue(withIdentifier: "segueToFriendsMemorials", sender: nil)
        case tableViewFriendRequestList:
            var alertStyle = UIAlertController.Style.alert
            if (UIDevice.current.userInterfaceIdiom == .pad) {
              alertStyle = UIAlertController.Style.alert
            }
            let friendRequestAlert = UIAlertController(title: "Add this user to your Friends List?", message: "This will allow them to see all the memorials you have made and your private Memorials.", preferredStyle: alertStyle)
            let acceptFriendRequest = UIAlertAction(title: "Accept", style: .default, handler: { _ in
                if let row = self.tableViewFriendRequestList.indexPathForSelectedRow?.row, let friendRequestId = self.friendRequestsIdList?[row], let friendRequestUserName = self.friendNameRequestList?[row] {
                    self.friendRequestsIdList = self.friendRequestsIdList?.filter() { $0 != friendRequestId }
                    self.friendNameRequestList = self.friendNameRequestList?.filter() { $0 != friendRequestUserName }
                    self.friendIdList?.append(friendRequestId)
                    print(self.friendIdList)
                    self.friendNameList?.append(friendRequestUserName)
                    self.friendIdListToBeAdded?.append(friendRequestId)
                    print(self.friendIdListToBeAdded)
                    tableView.reloadData()
                    self.tableViewFriendList.reloadData()
                }
            })
            friendRequestAlert.addAction(acceptFriendRequest)
            let dismiss = UIAlertAction(title: "Decline", style: .default, handler: { _ in
                if let row = self.tableViewFriendRequestList.indexPathForSelectedRow?.row, let friendId = self.friendRequestsIdList?[row], let friendRequestUserName = self.friendNameRequestList?[row] {
                    self.friendRequestsIdList = self.friendRequestsIdList?.filter() { $0 != friendId }
                    self.friendNameRequestList = self.friendNameRequestList?.filter() { $0 != friendRequestUserName }
                    tableView.reloadData()
                }
            })
            friendRequestAlert.addAction(dismiss)
            let IgnoreUser = UIAlertAction(title: "Block", style: .default, handler: { _ in
                if let row = self.tableViewFriendRequestList.indexPathForSelectedRow?.row, let friendRequestId = self.friendRequestsIdList?[row], let friendRequestUserName = self.friendNameRequestList?[row] {
                    self.friendRequestsIdList = self.friendRequestsIdList?.filter() { $0 != friendRequestId }
                    self.friendNameRequestList = self.friendNameRequestList?.filter() { $0 != friendRequestUserName }
                    self.ignoreIdList?.append(friendRequestId)
                    self.ignoreNameList?.append(friendRequestUserName)
                    tableView.reloadData()
                    self.tableViewIgnoreList.reloadData()
                }
            })
            friendRequestAlert.addAction(IgnoreUser)
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
                if let row = self.tableViewIgnoreList.indexPathForSelectedRow?.row, let blockedUserId = self.ignoreIdList?[row], let blockedUserName = self.ignoreNameList?[row] {
                    self.ignoreIdList = self.ignoreIdList?.filter(){$0 != blockedUserId }
                    self.ignoreNameList = self.ignoreNameList?.filter(){$0 != blockedUserName }
                    print(self.ignoreIdList)
                    tableView.reloadData()
                }
            })
            removeIgnoreAlert.addAction(goToLogIn)
            self.present(removeIgnoreAlert, animated: true, completion: nil)
        default:
            switch (indexPath.section, indexPath.row) {
            case (1,0):
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
            case (2,0):
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
            case (3,0):
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
            if tableView == tableViewMain {
                return 75
            } else {
                return 0
            }
        case (0,1):
            if tableView == tableViewMain {
                return 95
            } else {
                return 75
            }
        case (1,0):
            return 60
        case (1,1):
            switch friendListIsExpanded {
            case true:
                return 345
            case false:
                return 0
            }
        case (2,0):
            return 60
        case (2,1):
            switch friendRequestListIsExpanded {
            case true:
                return 345
            case false:
                return 0
            }
        case (3,0):
            return 60
        case (3,1):
            switch ignoreListIsExpanded {
            case true:
                return 345
            case false:
                return 0
            }
        default:
            return 75
        }
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == self.tableViewFriendList {
            if editingStyle == .delete {
                // Delete the row from the data source
                guard let toBeRemovedFriendId = self.friendIdList?.remove(at: indexPath.row) else { return }
                print(toBeRemovedFriendId)
                print(friendIdList?.count)
//                self.friendIdList?.remove(at: indexPath.row)
                self.friendNameList?.remove(at: indexPath.row)
                self.toBeRemovedFriendIdList?.append(toBeRemovedFriendId)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                return
            }
        }
        //else if editingStyle == .insert {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
    
    // MARK: - Functions
    
    func getUserData() {
        guard let currentUserAuthID: String = self.currentAuthID else { return }
        let userRef = self.db.collection("userProfile").whereField("userAuthId", isEqualTo: currentUserAuthID)
        userRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    if let premiumStatus = document.data()["premiumStatus"] as? Int,
                       let userName = document.data()["userName"] as? String,
                       let friendIdList = document.data()["friendIdList"] as? Array<String>,
                       let friendNameList = document.data()["friendNameList"] as? Array<String>,
                       let friendIdRequests = document.data()["friendIdRequestList"] as? Array<String>,
                       let friendNameRequests = document.data()["friendNameRequestList"] as? Array<String>,
                       let ignoredIdList = document.data()["ignoredIdList"] as? Array<String>,
                       let ignoredNameList = document.data()["ignoredNameList"] as? Array<String> {
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
                        self.friendIdList = friendIdList
                        self.friendNameList = friendNameList
                        self.friendRequestsIdList = friendIdRequests
                        self.friendNameRequestList = friendNameRequests
                        self.ignoreIdList = ignoredIdList
                        self.ignoreNameList = ignoredNameList
//                        self.getFriendUserName()
//                        self.getFriendRequestUserName()
//                        self.getIgnoreUserName()
                        self.tableViewFriendList.reloadData()
                        self.tableViewFriendRequestList.reloadData()
                        self.tableViewIgnoreList.reloadData()
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
    
    func getFriendUserName() { // OLD CODE
        guard let safeFriendUIDList = self.friendIdList else { return }
        for userName in safeFriendUIDList {
            let userRef = self.db.collection("userProfile").whereField("userAuthId", isEqualTo: userName)
            userRef.getDocuments { (snapshot, error) in
                if error != nil {
                    print(error as Any)
                } else {
                    for document in (snapshot?.documents)! {
                        print(document.data())
                        if let userName = document.data()["userName"] as? String {
                            print(userName)
                            self.friendNameList?.append(userName)
                            self.tableViewFriendList.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func getFriendRequestUserName() { // OLD CODE
        guard let SafeFriendRequestUIDList = self.friendRequestsIdList else { return }
        for userName in SafeFriendRequestUIDList  {
            let userRef = self.db.collection("userProfile").whereField("userAuthId", isEqualTo: userName)
            userRef.getDocuments { (snapshot, error) in
                if error != nil {
                    print(error as Any)
                } else {
                    for document in (snapshot?.documents)! {
                        if let userName = document.data()["userName"] as? String {
                            self.friendNameRequestList?.append(userName)
                            self.tableViewFriendRequestList.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func getIgnoreUserName() { // OLD CODE
        guard let SafeIgnoreUIDList = self.ignoreIdList else { return }
        for userName in SafeIgnoreUIDList  {
            let userRef = self.db.collection("userProfile").whereField("userAuthId", isEqualTo: userName)
            userRef.getDocuments { (snapshot, error) in
                if error != nil {
                    print(error as Any)
                } else {
                    for document in (snapshot?.documents)! {
                        if let userName = document.data()["userName"] as? String {
                            self.ignoreNameList?.append(userName)
                            self.tableViewIgnoreList.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func addFriends() {
        guard let friendIdListToBeAdded = self.friendIdListToBeAdded,
              let userName = self.userNameTextField.text,
              let currentAuthId = self.currentAuthID else { return }
        for friendId in friendIdListToBeAdded {
            let userRef = db.collection("userProfile").whereField("userAuthId",  isEqualTo: friendId)
            userRef.getDocuments { (snapshot, err) in
                if err != nil {
                    print(err as Any)
                } else {
                    for document in (snapshot?.documents)! {
                        guard var friendIdList = document.data()["friendIdList"] as? Array<String>,
                              var friendNameList = document.data()["friendNameList"] as? Array<String> else { return }
                        friendIdList.append(currentAuthId)
                        let newFriendIdList = friendIdList
                        friendNameList.append(userName)
                        let newFriendNameList = friendNameList
                        self.db.collection("userProfile").document(friendId).updateData([
                            "friendIdList": newFriendIdList,
                            "friendNameList": newFriendNameList
                        ]) { err in
                            if let err = err {
                                print(err)
                            } else {
                                //you are now on their friend list! ^_^
                            }
                        }
                    }
                }
            }
        }
    }
    
    func removeFriends() { // if it fails then just call it when it it removes one on case it messes the order up
        guard let removedFriends = self.toBeRemovedFriendIdList,
              let currentAuthID = self.currentAuthID  else { return }
        for removedFriend in removedFriends {
            let userRef = db.collection("userProfile").whereField("userAuthId", isEqualTo: removedFriend)
            userRef.getDocuments { (snapshot, err) in
                if err != nil {
                    print(err as Any)
                } else {
                    for document in (snapshot?.documents)! {
                        if let friendIdList = document.data()["friendIdList"] as? Array<String>,
                           var friendNameList = document.data()["friendNameList"] as? Array<String> {
                            guard let indexOfCurrentAuthId = friendIdList.firstIndex(of: currentAuthID ) else { return }
                            print(indexOfCurrentAuthId)
                            let newFriendIdList = friendIdList.filter(){$0 != currentAuthID }
                            let newFriendNameList = friendNameList.remove(at: indexOfCurrentAuthId)
                            
                            self.db.collection("userProfile").document(removedFriend).updateData([
                                "friendIdList": newFriendIdList,
                                "friendNameList": newFriendNameList
                            ]) { err in
                                if let err = err {
                                    print(err)
                                } else {
                                    //friend has forced you to remove him ;-;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func updateUserData() {
        db = Firestore.firestore()
        guard let userName = self.userNameTextField.text else { return }
        if userName == "" {
            userNameTextField.isError(baseColor: UIColor.gray.cgColor, numberOfShakes: 3, revert: true)
            return
        }
        
        guard let friendIdList = self.friendIdList,
              let friendNameList = self.friendNameList,
              let friendNameRequestList = self.friendNameRequestList,
              let friendRequestsIdList = self.friendRequestsIdList,
              let ignoreIdList = self.ignoreIdList,
              let ignoreNameList = self.ignoreNameList else { return }
        
        guard let currentId = currentAuthID else { return }
        db.collection("userProfile").document(currentId).updateData([ //.updateData([
//            "dataCount": MyFirebase.currentDataUsage!,
            "userName": userName,
            "friendIdList": friendIdList,
            "friendNameList": friendNameList,
            "friendIdRequestList": friendRequestsIdList,
            "friendNameRequestList": friendNameRequestList,
            "ignoredIdList": ignoreIdList,
            "ignoreNameList": ignoreNameList
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
                MyFirebase.currentUserName = userName
                self.removeFriends()
                self.addFriends()
                var alertStyle = UIAlertController.Style.alert
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    alertStyle = UIAlertController.Style.alert
                }
                let alertAccountSaved = UIAlertController(title: "Account Saved!", message: "", preferredStyle: alertStyle)
                alertAccountSaved.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.performSegue(withIdentifier: "unwindToMap", sender: nil)
                    alertAccountSaved.dismiss(animated: true, completion: nil)
                }))
                self.present(alertAccountSaved, animated: true, completion: nil)
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
                print("Document successfully updated")
            }
        }
    }
    
    func changeBackground() { // this will cause a freeze
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "bookshelf")
        backgroundImage.contentMode = UIView.ContentMode.scaleToFill
        self.tableViewFriendList.backgroundView = backgroundImage
        self.tableViewFriendRequestList.backgroundView = backgroundImage
        self.tableViewIgnoreList.backgroundView = backgroundImage
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToFriendsMemorials", let memorialsTVC = segue.destination as? MemorialsTableViewController {
            if let row = self.tableViewFriendList.indexPathForSelectedRow?.row, let friendMemorial = friendIdList?[row] {
                memorialsTVC.currentAuthId = friendMemorial
            }
        }
    }
    
    // MARK: - Actions

    @IBAction func saveAccountBarButtonTapped(_ sender: UIBarButtonItem) {
        self.updateUserData()
    }
    
    @IBAction func unwindToMap(_ sender: UIStoryboardSegue) {}
    
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
