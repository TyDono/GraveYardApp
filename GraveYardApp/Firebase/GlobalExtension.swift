//
//  GlobalExtension.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 11/7/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

func moveToMap() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
    appDelegate.window?.makeKeyAndVisible()
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let mapVC = storyboard.instantiateViewController(withIdentifier: "map")
    appDelegate.window?.rootViewController = mapVC
}
