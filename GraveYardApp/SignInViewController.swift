//
//  SignInViewController.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/17/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import Firebase

class SignInViewController: UIViewController, GIDSignInUIDelegate {
    
    var db: Firestore!
    var userId: String = ""
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.uiDelegate = self
        db = Firestore.firestore()
    }
    
        func whiteStatusBar() -> UIStatusBarStyle{
            return UIStatusBarStyle.lightContent
        }
    
    @IBAction func googleSignIn(_ sender: Any) {
        
    }

}
