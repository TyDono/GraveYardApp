//
//  MyFirebase.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/17/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//


import Foundation
import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore
import Firebase

class MyFirebase {
    
    // Variables
    static let shared = MyFirebase()
    
    var db = Firestore.firestore()
    var currentAuthID = Auth.auth().currentUser?.uid
    var userId: String? = ""
    var currentUser: User?
    var storage = Storage.storage().reference()
    let formatter = DateFormatter()
    
    private var listenHandler: AuthStateDidChangeListenerHandle?
    var currentUpload:StorageUploadTask?
    
    func addUserListender(loggedIn: Bool) {
        print("Add listener")
        listenHandler = Auth.auth().addStateDidChangeListener{ (auth, user) in
            if user == nil {
                //logged Out
                self.currentUser = nil
                print("You Are Currently Logged Out")
                self.currentAuthID = nil
                self.userId = ""
            } else {
                print("Logged In")
                let userReff = self.db.collection("userProfile").document("\(String(describing: self.userId))")
                userReff.getDocument { (document, error) in
                    if let document = document {
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        print("data already added: \(dataDescription)")
                    } else {
                        self.createData()
                    }
                    self.currentUser = user
                    self.userId = (user?.uid)!
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        print(self.currentAuthID, "logged in")
                        moveToMap()
                    }
                }
            }
        }
    }
    
    func createData() {
        let currentUserId: String = ""
        let premiumStatus: Bool = false
        
        let user = UserProfile(currentAuthId: currentUserId,
                               premiumStatus: premiumStatus)
        
        let userRef = self.db.collection("userProfile")
        userRef.document(String(user.currentAuthId)).setData(user.dictionary) { err in
            if let err = err {
                print(err)
            } else {
                print("Added Data")
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
        try! Auth.auth().signOut()
        self.currentAuthID = nil
        GIDSignIn.sharedInstance()?.signIn()
    }
    
}
