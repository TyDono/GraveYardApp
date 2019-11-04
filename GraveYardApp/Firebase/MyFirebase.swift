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
    var currentUser: User?
    var userId: String? = ""
    var storage = Storage.storage().reference()
    let formatter = DateFormatter()
    
    private var listenHandler: AuthStateDidChangeListenerHandle?
    var currentUpload:StorageUploadTask?
    
    func addUserListender(loggedIn: Bool) {}
    
//    func createData() {
//        
//        // IDEA, image of a folder, image that tells them what it is. is is a text doc is it pics? is ait a video? is it multiple? when u make a story ONE VC.
//        // when the id are made, a check to search for ids of the same must be made. if they are the same, rinse and repeat.
//        
//        let id = currentAuthID!
//        let graveId = String(arc4random_uniform(999999999)) + "id" //try UUID()
//        let newGraveId = String(arc4random_uniform(999999999)) + "id"
//        let storyId = graveId + String(arc4random_uniform(999999999))
//        let name: String = ""
//        let birthDate: String = ""
//        let birthLocation: String = ""
//        let deathDate: String = ""
//        let deathLocation: String = ""
//        let marriageStatus: String = ""
//        let bio: String = ""
//        
//        var grave = Grave(creatorId: id,
//                          graveId: graveId,
//                          name: name,
//                          birthDate: birthDate,
//                          birthLocation: birthLocation,
//                          deathDate: deathDate,
//                          deathLocation: deathLocation,
//                          marriageStatus: marriageStatus,
//                          bio: bio,
//                          graveLocation: currentGraveLocation)
//        
//        let graveRef = self.db.collection("grave")
//        graveRef.whereField("graveId", isEqualTo: grave.graveId).getDocuments { (snapshot, error) in
//            if error != nil {
//                print(Error.self)
//            } else {
//                if snapshot?.description == grave.graveId {
//                    grave.graveId = newGraveId
//                } else {
//                    print("no dupli")
//                }
//            }
//        }
//        graveRef.document(String(grave.graveId)).setData(grave.dictionary) { err in
//            if let err = err {
//                print(err)
//            } else {
//                print("Added Data")
//            }
//        }
//    }
    
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

