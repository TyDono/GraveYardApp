//
//  MyFirebase.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/17/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//


import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore
import FirebaseStorage

class MyFirebase {
    
    // MARK: - Propeties
    
    static let shared = MyFirebase()
//    static var currentDataUsage: Double?
    static var currentUserName: String?
    static var memorialCount: Int = 0
    
    var db = Firestore.firestore()
    var currentAuthID = Auth.auth().currentUser?.uid
    var userId = ""
    var currentUser: User?
    var storage = Storage.storage().reference()
    let formatter = DateFormatter()
    var currentUserPremiumStatus: Bool = false
    
    private var listenHandler: AuthStateDidChangeListenerHandle?
    var currentUpload:StorageUploadTask?
    
    // MARK: - Functions
    
    func addUserListender(loggedIn: Bool) {
        print("Add listener")
        listenHandler = Auth.auth().addStateDidChangeListener{ (auth, user) in
            if user == nil {
                //logged Out
                self.currentUser = nil
                self.currentAuthID = nil
                self.userId = ""
                print("You Are Currently Logged Out")
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    if loggedIn == true {
                        moveToMap()
                    } else {
                        //moveToMap()
                    }
                }
            } else {
                self.userId = user?.uid ?? "Error, No current Auth ID detected!"
                print("Logged In")
                let userReff = self.db.collection("userProfile").document("\(String(describing: self.userId))")
                userReff.getDocument { (document, error) in
                    print(document?.exists)
                    guard let document = document?.exists else { return }
                    if document == true {
                        //let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        print("data already added: \(document)")
                    } else {
                        self.createData()
                    }
                    self.currentUser = user
                    self.userId = (user?.uid)!
                    print("UserID: \(self.userId )")
                    self.getCurrentUserData()
                    //call function to call for user premium statatus and set the var premiumStatus
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        print(self.userId, "is logged in")
                        //moveToMap()
                    }
                }
            }
        }
    }
    
    func createData() {
        let currentUserId: String = self.userId
        let premiumStatus: Int = 0
        let dataCount: Double = 0.0
        let userName: String = ""
        let friendIdList: Array<String> = [""]
        let friendNameList: Array<String> = [""]
        let friendIdRequestList: Array<String> = [""]
        let friendNameRequestList: Array<String> = [""]
        let ignoredIdList: Array<String> = [""]
        let ignoredNameList: Array<String> = [""]
        let memorialCount: Int = 0
        
        let user = UserProfile(userAuthId: currentUserId,
                               premiumStatus: premiumStatus,
                               dataCount: dataCount,
                               userName: userName,
                               friendIdList: friendIdList,
                               friendNameList: friendNameList,
                               friendIdRequestList: friendIdRequestList,
                               friendNameRequestList: friendNameRequestList,
                               ignoredIdList: ignoredIdList,
                               ignoredNameList: ignoredNameList,
                               memorialCount: memorialCount)
        
        let userRef = self.db.collection("userProfile")
        userRef.document(user.userAuthId).setData(user.dictionary) { err in
            if let err = err {
                print(err)
            } else {
//                MyFirebase.currentDataUsage = dataCount
                print("Added Data")
            }
        }
    }
    
    func getCurrentUserData() {
        let graveRef = self.db.collection("userProfile").whereField("userAuthId", isEqualTo: self.userId) //change this to the grave id that was tapped, NOT THE USER ID. THE USER ID IS FOR DIF STUFF. use String(arc4random_uniform(99999999)) to generate the grave Id when created
        graveRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error as Any)
            } else {
                for document in (snapshot?.documents)! {
                    if let premiumStatus = document.data()["premiumStatus"] as? Bool,
                        let memorialCount = document.data()["memorialCount"] as? Int,
                        let dataCount = document.data()["dataCount"] as? Double,
                        let userName = document.data()["userName"] as? String {
                        self.currentUserPremiumStatus = premiumStatus
                        MyFirebase.memorialCount = memorialCount
//                        MyFirebase.currentDataUsage = dataCount
                        MyFirebase.currentUserName = userName
                        
                    }
                }
            }
        }
    }
    
    func removeUserListener() {
        guard listenHandler != nil else {
            return
        }
        Auth.auth().removeStateDidChangeListener(listenHandler!)
    }
    
    func isLoggedIn() -> Bool {
        return(currentAuthID != nil)
    }
    
    func logOut() {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        self.currentAuthID = nil
//        GIDSignIn.sharedInstance.signIn()
    }
    
}
