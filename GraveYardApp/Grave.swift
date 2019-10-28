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
    var birth: String
    var death: String
    var marriageStatus: String?
    var bio: String
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "name": name,
            "birth": birth,
            "death": death,
            "marriageStatus": marriageStatus ?? "", //when, where, who
            "bio": bio
        ]
    }
}

extension Grave: DocumentUserSerializable {
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
            let name = dictionary["name"] as? String,
            let birth = dictionary["birth"] as? String,
            let death = dictionary["death"] as? String,
            let marriageStatus = dictionary["marriageStatus"] as? String?,
            let bio = dictionary["bio"] as? String else {return nil}
        self.init(id: id, name: name, birth: birth, death: death, marriageStatus: marriageStatus, bio: bio)
    }
    
}
