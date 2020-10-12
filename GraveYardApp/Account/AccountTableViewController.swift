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
    
    @IBOutlet weak var tableViewFriendsLists: UITableView!
    @IBOutlet weak var tableViewFriendRequestList: UITableView!
    @IBOutlet weak var tableViewFriendIgnoreListList: UITableView!
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

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        self.registerStaticCells()
        getUserData()
        changeBackground()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return super.numberOfSections(in: tableView) - 1
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
        case tableViewFriendIgnoreListList:
            return self.ignoreNameList?.count ?? 0
        default:
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            return super.tableView(tableView, cellForRowAt: indexPath)
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "premiumStatusCell", for: indexPath) as? PremiumStatusStaticTableViewCell else { return UITableViewCell() }
//            cell.premiumStatusLabel.text = self.premiumStatus
//            return cell
        case (0,1):
            return super.tableView(tableView, cellForRowAt: indexPath)
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "userNameCell", for: indexPath) as? UserNameStaticTableViewCell else { return UITableViewCell() }
//            cell.userNameTextField.text = self.userName
//            return cell
        case (1,0):
            return super.tableView(tableView, cellForRowAt: indexPath)
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendListExpanderCell", for: indexPath) as? FriendListExpanderTableViewCell else { return UITableViewCell() }
//            cell.friendListLabel.text = "Expander Friend List"
//            return cell
        case (1,1):
            return super.tableView(tableView, cellForRowAt: indexPath)
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendListCell", for: indexPath) as? FriendListTableViewCell else { return UITableViewCell() }

//            return cell
        default:
            return UITableViewCell()
        }
        
        switch tableView {
        case tableViewFriendsLists:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendListDynamicCell", for: indexPath) as? FriendListDynamicTableViewCell else { return UITableViewCell() }
            cell.backgroundColor = UIColor.clear
            cell.backgroundView = UIImageView.init(image: UIImage.init(named: "bookRed"))
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
            cell.backgroundColor = UIColor.clear
            cell.backgroundView = UIImageView.init(image: UIImage.init(named: "bookRed"))
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
            
        case tableViewFriendIgnoreListList:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "IgnoreListCell", for: indexPath) as? IgnoreListTableViewCell else { return UITableViewCell() }
            cell.backgroundColor = UIColor.clear
            cell.backgroundView = UIImageView.init(image: UIImage.init(named: "bookRed"))
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
            /*
            switch (indexPath.section, indexPath.row) {
            case (0,0):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "premiumStatusCell", for: indexPath) as? PremiumStatusStaticTableViewCell else { return UITableViewCell() }
                cell.premiumStatusLabel.text = self.premiumStatus
                return cell
            case (0,1):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "userNameCell", for: indexPath) as? UserNameStaticTableViewCell else { return UITableViewCell() }
                cell.userNameTextField.text = self.userName
                return cell
            case (0,2):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendListExpanderCell", for: indexPath) as? FriendListExpanderTableViewCell else { return UITableViewCell() }
                cell.friendListLabel.text = "Expander Friend List"
                return cell
            case (1,0):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendListCell", for: indexPath) as? FriendListTableViewCell else { return UITableViewCell() }
    
                return cell
            default:
                return UITableViewCell()
            }
            */
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "premiumStatusCell", for: indexPath) as? PremiumStatusStaticTableViewCell else { return UITableViewCell() }
            switch cell.reuseIdentifier {
            case "premiumStatusCell":
                cell.premiumStatusLabel.text = self.premiumStatus
                return cell
            case "userNameCell":
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "userNameCell", for: indexPath) as? UserNameStaticTableViewCell else { return UITableViewCell() }
                return cell
            case "friendsListExpanderCell":
                return cell
            case "friendsListCell":
                return cell

            case "friendRequestExpanderCell":
                return cell
            case "FriendRequestCell":
                return cell

            case "ignoreExpanderCell":
                return cell
            case "ignoreListCell":
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToFriendsMemorials", let memorialsTVC = segue.destination as? MemorialsTableViewController {
            if let row = self.tableView.indexPathForSelectedRow?.row, let friendMemorial = friendUIDList?[row] {
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
            if let row = self.tableView.indexPathForSelectedRow?.row, let friendId = self.friendRequestsUIDList?[row], let friendRequestUserName = self.friendNameRequestsList?[row] {
                self.friendRequestsUIDList = self.friendRequestsUIDList?.filter(){$0 != friendId}
                self.friendNameRequestsList = self.friendNameRequestsList?.filter(){$0 != friendRequestUserName}
                self.tableViewFriendRequestList.reloadData()
            }
            friendRequestAlert.addAction(dismiss)
            let goToLogIn = UIAlertAction(title: "Accept", style: .default, handler: { _ in
                if let row = self.tableView.indexPathForSelectedRow?.row, let friendRequestId = self.friendRequestsUIDList?[row], let friendRequestUserName = self.friendNameRequestsList?[row] {
                    self.friendRequestsUIDList = self.friendRequestsUIDList?.filter(){$0 != friendRequestId}
                    self.friendNameRequestsList = self.friendNameRequestsList?.filter(){$0 != friendRequestUserName}
                    self.friendUIDList?.append(friendRequestId)
                    self.tableViewFriendsLists.reloadData()
                    self.tableViewFriendRequestList.reloadData()
                }
            })
            friendRequestAlert.addAction(goToLogIn)
            self.present(friendRequestAlert, animated: true, completion: nil)
        case tableViewFriendIgnoreListList:
            var alertStyle = UIAlertController.Style.alert
            if (UIDevice.current.userInterfaceIdiom == .pad) {
              alertStyle = UIAlertController.Style.alert
            }
            let removeIgnoreAlert = UIAlertController(title: "Unblock this user?", message: "This will allow the user to once again send you friend requests", preferredStyle: alertStyle)
            let dismiss = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            removeIgnoreAlert.addAction(dismiss)
            let goToLogIn = UIAlertAction(title: "Unblock", style: .default, handler: { _ in
                if let row = self.tableView.indexPathForSelectedRow?.row, let blockedUserId = self.ignoreUIDList?[row], let blockedUserName = self.ignoreNameList?[row] {
                    self.ignoreUIDList = self.ignoreUIDList?.filter(){$0 != blockedUserId }
                    self.ignoreNameList = self.ignoreNameList?.filter(){$0 != blockedUserName }
                    self.tableViewFriendRequestList.reloadData()
                }
            })
            removeIgnoreAlert.addAction(goToLogIn)
            self.present(removeIgnoreAlert, animated: true, completion: nil)
        default:
            return
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
    
    private func registerStaticCells() {
        let premiumCell = UINib(nibName: "PremiumStatusStaticTableViewCell", bundle: nil)
        self.tableView.register(premiumCell, forCellReuseIdentifier: "premiumStatusCell")
        
        let userNameCell = UINib(nibName: "UserNameStaticTableViewCell", bundle: nil)
        self.tableView.register(userNameCell, forCellReuseIdentifier: "userNameCell")
        
        let friendListExpanderCell = UINib(nibName: "FriendListExpanderTableViewCell", bundle: nil)
        self.tableView.register(friendListExpanderCell, forCellReuseIdentifier: "friendListExpanderCell")
        
//        let friendListCell = UINib(nibName: "FriendListTableViewCell", bundle: nil)
//        self.tableView.register(friendListCell, forCellReuseIdentifier: "friendListCell")
    }
    
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
                       let blockedList = document.data()["blockedList"] as? Array<String> {
                        //self.dataCount = Double(dataCount)
                        switch premiumStatus {
                        case 0:
                            self.premiumStatus = "You are not currently subscribed to Remembrances Premium"
                        case 1:
                            self.premiumStatus = "Your current subsciption is Tier 1"
                        case 2:
                            self.premiumStatus = "Your current subsciption is Tier 2"
                        case 3:
                            self.premiumStatus = "Your current subsciption is Tier 3"
                        default:
                            self.premiumStatus = ""
                        }
                        self.userName = userName
                        self.friendUIDList = friendList
                        self.friendRequestsUIDList = friendRequests
                        self.ignoreUIDList = blockedList
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
                            self.tableViewFriendIgnoreListList.reloadData()
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
            "friendList": self.friendNameList ?? "" ,
            "friendRequests": self.friendNameRequestsList ?? "" ,
            "blockedList": self.ignoreNameList ?? ""
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
