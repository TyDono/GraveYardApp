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

protocol DocumentUserSerializable {
    init?(dictionary: [String: Any])
}

struct Grave {
    var id: String // this is the googleSign in userId
    var name: String //name of dead person
    var birthDate: String
    var birthLocation: String
    var deathDate: String
    var deathLocation: String
    var marriageStatus: String?
    var bio: String
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "name": name,
            "birth": birthDate,
            "birthLocation": birthLocation,
            "death": deathDate,
            "deathLocation": deathLocation,
            "marriageStatus": marriageStatus ?? "", //when, where, who
            "bio": bio
        ]
    }
}

extension Grave: DocumentUserSerializable {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
            let name = dictionary["name"] as? String,
            let birthDate = dictionary["birthDate"] as? String,
            let birthLocation = dictionary["birthLocation"] as? String,
            let deathDate = dictionary["deathDate"] as? String,
            let deathLocation = dictionary["deathLocation"] as? String,
            let marriageStatus = dictionary["marriageStatus"] as? String?,
            let bio = dictionary["bio"] as? String else {return nil}
        self.init(id: id, name: name, birthDate: birthDate, birthLocation: birthLocation, deathDate: deathDate, deathLocation: deathLocation, marriageStatus: marriageStatus, bio: bio)
    }
    
}
