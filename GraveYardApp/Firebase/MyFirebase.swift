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
    var storage = Storage.storage().reference()
    let formatter = DateFormatter()
    
    private var listenHandler: AuthStateDidChangeListenerHandle?
    var currentUpload:StorageUploadTask?
    
    func addUserListender(loggedIn: Bool) {
        print("Add listener")
        listenHandler = Auth.auth().addStateDidChangeListener{ (auth, user) in
            if user == nil {
                //logged Out
                print("You Are Currently Logged Out")
                self.currentAuthID = nil
                self.userId = ""
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    print(self.currentAuthID, "logged in")
                    moveToMap()
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
        try! Auth.auth().signOut()
        self.currentAuthID = nil
        GIDSignIn.sharedInstance()?.signIn()
    }
    
}

