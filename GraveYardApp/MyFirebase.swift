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
    
    //var dataBse = Database.database().reference().child("messages")
    var db = Firestore.firestore()
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentUser: User?
    var userId: String? = ""
    var storage = Storage.storage().reference()
    let formatter = DateFormatter()
    
    private var listenHandler: AuthStateDidChangeListenerHandle?
    var currentUpload:StorageUploadTask?
    
    func addUserListender(loggedIn: Bool) {
        
    }
    
    func createData() {
        
        let id = currentAuthID!
        let name: String = ""
        let birthDate: String = ""
        let birthLocation: String = ""
        let deathDate: String = ""
        let deathLocation: String = ""
        let bio: String = ""
        
        let grave = Grave(id: id,
                          name: name,
                          birthDate: birthDate,
                          birthLocation: birthLocation,
                          deathDate: deathDate,
                          deathLocation: deathLocation,
                          bio: bio)
        
        let userRef = self.db.collection("grave")
        userRef.document(String(grave.id)).setData(grave.dictionary) { err in
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
        return(currentUser != nil)
    }
    
    func liknCredential(credential: AuthCredential) {
        currentUser?.link(with: credential) {
            (user, error) in
            
            if let error = error {
                print(error)
                return
            }
            print("Credential linked")
        }
    }
    
    func logOut() {
        try! Auth.auth().signOut()
        GIDSignIn.sharedInstance()?.signIn()
    }
    
}

