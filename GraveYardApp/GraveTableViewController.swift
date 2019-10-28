//
//  GraveTableViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/28/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class GraveTableViewController: UITableViewController {
    @IBOutlet weak var graveMainImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var marriageStatusLabel: UILabel!
    @IBOutlet weak var birthLabel: UILabel!
    @IBOutlet weak var deathLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentUser: Grave?

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        getGraveData()
    }

    // MARK: - Table view data source

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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

     func getGraveData() {
           guard let uId: String = self.currentAuthID else { return }
           print("this is my uid i really like my uid \(uId)")
           let graveRef = self.db.collection("grave").whereField("id", isEqualTo: uId) //change this to the id that was tapped
           graveRef.getDocuments { (snapshot, error) in
               if error != nil {
                   print(error as Any)
               } else {
                   for document in (snapshot?.documents)! {
                       if let name = document.data()["name"] as? String,
                           let birth = document.data()["birth"] as? String,
                           let death = document.data()["death"] as? String,
                           let marriageStatus = document.data()["marriageStatus"] as? String,
                           let bio = document.data()["bio"] as? String {
                           
                           self.nameLabel.text = name
                           self.marriageStatusLabel.text = birth
                           self.birthLabel.text = death
                           self.marriageStatusLabel.text = marriageStatus
                           self.bioLabel.text = bio
                       }
                   }
               }
           }
       }

}
