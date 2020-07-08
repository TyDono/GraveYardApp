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

class AccountViewController: UIViewController {

    @IBOutlet weak var dataCountLabel: UILabel!
    @IBOutlet weak var premiumStatusLabel: UILabel!
    
    // MARK: - Propeties
    
    var currentAuthID = Auth.auth().currentUser?.uid
    var db: Firestore!
    var dataCount: Int = 0
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserData()
        self.premiumStatusLabel.text = "Premium accounts comming soon!"
        if dataCount != 0 {
            let dividedDataCount: Int = self.dataCount/1000
            let stringDataCount: String = String(dividedDataCount)
            self.dataCountLabel.text = "\(stringDataCount) kb / 5,000 kb"
        } else {
            self.dataCountLabel.text = "0 kb / 5,000 kb"
        }
        
    }
    
    func getUserData() {
        guard let currentUserAuthID: String = self.currentAuthID else { return }
        let userRef = self.db.collection("user").whereField("currentUserAuthID", isEqualTo: currentUserAuthID)
        userRef.getDocuments { (snapshot, error) in
            if error != nil {
                print(error)
            } else {
                for document in (snapshot?.documents)! {
                    if let dataCount = document.data()["dataCount"] as? Int {
                        self.dataCount = dataCount
                    }
                }
            }
        }
    }
    
    func updateUserData() {
        db = Firestore.firestore()
        guard let currentId = currentAuthID else { return }
        db.collection("userProfile").document(currentId).updateData([
            "dataCount": MyFirebase.currentDataUsage
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }

}
