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
    
    // MARK: - Propeties
    
    var currentAuthID = Auth.auth().currentUser?.uid
    var db: Firestore!
    var userId: String = ""
    let userDefault = UserDefaults.standard
    private var listenHandler: AuthStateDidChangeListenerHandle?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chageTextColor()
        GIDSignIn.sharedInstance()?.uiDelegate = self
        db = Firestore.firestore()
        changeBackground()
    }
    
    // MARK: - Functions
    
    func chageTextColor() {
        navigationItem.leftBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(0.0, 128.0, 128.0, 1.0)
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
    
    // MARK: - Actions
    
    @IBAction func cancelSignUpButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func googleSignIn(_ sender: Any) {}
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        self.userId = ""
        try! Auth.auth().signOut()
    }
    
}
