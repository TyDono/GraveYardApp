//
//  MemorialsTableViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 8/24/20.
//  Copyright © 2020 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class MemorialsTableViewController: UITableViewController {
    
    var currentAuthId: String? = Auth.auth().currentUser?.uid
    var graveId: String?
    var graves: [Grave]?
    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        db = Firestore.firestore()
        getGraves()
        changeBackground()
    }
    
    func changeBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "bookshelf")
        backgroundImage.contentMode = UIView.ContentMode.scaleToFill
        self.tableView.backgroundView = backgroundImage
    }
    
    func getGraves() {
        var graves = [Grave]()
        guard let currentGraveCreatorId: String = currentAuthId else { return }
//        guard let currentGraveId: String = graveId else { return }
        print(currentGraveCreatorId)
        db.collection("grave").whereField("creatorId", isEqualTo: currentGraveCreatorId).getDocuments { (snapshot, error) in
                if error != nil {
                    print(Error.self)
                } else {
                    guard let snapshot = snapshot else {
                        print("could not unrwap snapshot")
                        return
                    }
                    for document in (snapshot.documents) {
                        if let gravesResult = document.data() as? [String: Any], let otherGraves = Grave.init(dictionary: gravesResult) {
                            graves.append(otherGraves)
                        }
                    }
                    self.graves = graves
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return graves?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "memorialCell", for: indexPath) as? MemorialsTableViewCell else { return UITableViewCell() }
        
        cell.backgroundColor = UIColor.clear
        cell.backgroundView = UIImageView.init(image: UIImage.init(named: "bookRed"))
        
        if let memorials = graves {
            let story = memorials[indexPath.row]
            cell.cellTitle.text = "\(story.name)"
            
            let maskLayer = CAShapeLayer()
            let bounds = cell.bounds
            maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 7, width: bounds.width-4, height: bounds.height-4), cornerRadius: 5).cgPath
            cell.layer.mask = maskLayer
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "graveSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let row = self.tableView.indexPathForSelectedRow?.row, let grave = graves?[row] {
            if segue.identifier == "graveSegue", let graveTVC = segue.destination as? GraveTableViewController {
                graveTVC.currentGraveId = grave.graveId
            }
        }
    }

}
