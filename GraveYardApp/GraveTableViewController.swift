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
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var birthLocationLabel: UILabel!
    @IBOutlet weak var deathDateLabel: UILabel!
    @IBOutlet weak var deathLocationLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    var db: Firestore!
    var currentAuthID = Auth.auth().currentUser?.uid
    var currentUser: Grave?
    var grave: [Grave]?
    var graveId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
       // changeBackground()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "graveStoriesSegue", let GraveStoriesTVC = segue.destination as? GraveStoriesTableViewController {
            
            GraveStoriesTVC.graveStories = graveId
        }
        print("prepare for segueSearch called")
    }
    
    func changeBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "GradientPlaceHolder")
        backgroundImage.contentMode = UIView.ContentMode.scaleToFill
        self.view.insertSubview(backgroundImage, at: 0)
    }

     func getGraveData() {
             guard let uId: String = self.currentAuthID else { return }
             print("this is my uid i really like my uid \(uId)")
             let graveRef = self.db.collection("grave").whereField("id", isEqualTo: uId) //change this to the grave id that was tapped, NOT THE USER ID. THE USER ID IS FOR DIF STUFF. use String(arc4random_uniform(99999999)) to generate the grave Id when created
             graveRef.getDocuments { (snapshot, error) in
                 if error != nil {
                     print(error as Any)
                 } else {
                     for document in (snapshot?.documents)! {
                         if let name = document.data()["name"] as? String,
                             let birthDate = document.data()["birthDate"] as? String,
                             let birthLocation = document.data()["birthLocation"] as? String,
                             let deathDate = document.data()["deathDate"] as? String,
                             let deathLocation = document.data()["deathLocation"] as? String,
                             let marriageStatus = document.data()["marriageStatus"] as? String,
                             let bio = document.data()["bio"] as? String {
     
                             self.nameLabel.text = name
                             self.marriageStatusLabel.text = marriageStatus
                             self.birthDateLabel.text = birthDate
                             self.birthLocationLabel.text = birthLocation
                             self.deathDateLabel.text = deathDate
                             self.deathLocationLabel.text = deathLocation
                             self.marriageStatusLabel.text = marriageStatus
                             self.bioLabel.text = bio
                         }
                     }
                 }
             }
         }
    
    @IBAction func editGraveBarButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editGraveSegue", sender: nil)
    }
    
}
