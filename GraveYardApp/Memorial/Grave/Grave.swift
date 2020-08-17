//
//  Grave.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/23/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

protocol Identifiable {
    var id: String? { get set }
}

protocol DocumentGraveSerializable {
    init?(dictionary: [String: Any])
}

struct Grave {
    var creatorId: String // this is the sign in userId
    var graveId: String // the grave specifict Id that is generated when the grave is created. each grave should have its own unique Id
    var profileImageId: String
    var name: String //name of dead person
    var birthDate: String
    var birthLocation: String
    var deathDate: String
    var deathLocation: String
    var familyStatus: String?
    var bio: String
    var graveLocationLatitude: String
    var graveLocationLongitude: String
    var allGraveIdentifier: String //this is used to locate pins and is needed for every pin
    var pinQuote: String
    var birthSwitchIsOn: Bool
    var deathSwitchIsOn: Bool
    var publicIsTrue: Bool
    var arrayOfStoryImageIDs: [String]
    // premium users, grave quote, grave node image
    // BURIAL LOCATION
    // coordanates = jim
    // coodinates
    
    //jim = annoatation.coodiante
    
    var dictionary: [String: Any] {
        return [
            "creatorId": creatorId,
            "graveId": graveId,
            "profileImageId": profileImageId,
            "name": name,
            "birthDate": birthDate,
            "birthLocation": birthLocation,
            "deathDate": deathDate,
            "deathLocation": deathLocation,
            "familyStatus": familyStatus ?? "",
            "bio": bio,
            "graveLocationLatitude": graveLocationLatitude,
            "graveLocationLongitude": graveLocationLongitude,
            "allGraveIdentifier": allGraveIdentifier,
            "pinQuote": pinQuote,
            "birthSwitchIsOn": birthSwitchIsOn,
            "deathSwitchIsOn": deathSwitchIsOn,
            "publicIsTrue": publicIsTrue,
            "arrayOfStoryImageIDs": arrayOfStoryImageIDs
        ]
    }
}

extension Grave: DocumentGraveSerializable {
    init?(dictionary: [String: Any]) {
        guard let creatorId = dictionary["creatorId"] as? String,
            let graveId = dictionary["graveId"] as? String,
            let profileImageId = dictionary["profileImageId"] as? String,
            let name = dictionary["name"] as? String,
            let birthDate = dictionary["birthDate"] as? String,
            let birthLocation = dictionary["birthLocation"] as? String,
            let deathDate = dictionary["deathDate"] as? String,
            let deathLocation = dictionary["deathLocation"] as? String,
            let familyStatus = dictionary["familyStatus"] as? String?,
            let bio = dictionary["bio"] as? String,
            let graveLocationLatitude = dictionary["graveLocationLatitude"] as? String,
            let graveLocationLongitude = dictionary["graveLocationLongitude"] as? String,
            let allGraveIdentifier = dictionary["allGraveIdentifier"] as? String,
            let pinQuote = dictionary["pinQuote"] as? String,
            let birthSwitchIsOn = dictionary["birthSwitchIsOn"] as? Bool,
            let deathSwitchIsOn = dictionary["deathSwitchIsOn"] as? Bool,
            let publicIsTrue = dictionary["publicIsTrue"] as? Bool,
            let arrayOfStoryImageIDs = dictionary["arrayOfStoryImageIDs"] as? [String] else {return nil}
        self.init(creatorId: creatorId, graveId: graveId, profileImageId: profileImageId, name: name, birthDate: birthDate, birthLocation: birthLocation, deathDate: deathDate, deathLocation: deathLocation, familyStatus: familyStatus, bio: bio, graveLocationLatitude: graveLocationLatitude, graveLocationLongitude: graveLocationLongitude, allGraveIdentifier: allGraveIdentifier, pinQuote: pinQuote, birthSwitchIsOn: birthSwitchIsOn, deathSwitchIsOn: deathSwitchIsOn, publicIsTrue: publicIsTrue, arrayOfStoryImageIDs: arrayOfStoryImageIDs)
    }
    
}
