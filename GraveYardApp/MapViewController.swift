//
//  MapViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/17/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class MapViewController: UIViewController {
    @IBOutlet weak var signUp: UIBarButtonItem!
    
    var currentAuthID = Auth.auth().currentUser?.uid
    var userId: String = ""
    var currentUser: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        checkForUserId()
    }
    
    func checkForUserId() {
        if currentAuthID == nil {
            signUp.title = "Sign Up"
        } else {
            signUp.title = "Log Out"
        }
    }
    
    @IBAction func SignInTapped(_ sender: UIBarButtonItem) {
        if currentAuthID == nil {
            performSegue(withIdentifier: "segueToSignUp", sender: self)
        } else {
            self.currentUser = nil
            self.userId = ""
            try! Auth.auth().signOut()
        }
    }
    
    @IBAction func unwindToMap(_ sender: UIStoryboardSegue) {
        
    }

}
