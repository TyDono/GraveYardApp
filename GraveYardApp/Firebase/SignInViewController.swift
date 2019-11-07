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
import FirebaseFirestore
import Firebase

class SignInViewController: UIViewController, GIDSignInUIDelegate {
    
    var currentAuthID = Auth.auth().currentUser?.uid
    var db: Firestore!
    var userId: String = ""
    let userDefault = UserDefaults.standard
     private var listenHandler: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.uiDelegate = self
        db = Firestore.firestore()
        changeBackground()
    }
    
    func changeBackground() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "GradientPlaceHolder")
        backgroundImage.contentMode = UIView.ContentMode.scaleToFill
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    func whiteStatusBar() -> UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction func cancelSignUpButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func googleSignIn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        self.userId = ""
        try! Auth.auth().signOut()
    }
    
}
