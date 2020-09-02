//
//  UserProfile.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 11/14/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

protocol IdentifiableUser {
    var id: String? { get set }
}

protocol DocumentSerializableUser {
    init?(dictionary: [String: Any])
}

struct UserProfile {
    var currentUserAuthId: String
    var premiumStatus: Bool
    var dataCount: Double
    var memorialCount: Int
    
    var dictionary: [String: Any] {
        return [
            "currentUserAuthId": currentUserAuthId,
            "premiumStatus": premiumStatus,
            "dataCount": dataCount,
            "memorialCount": memorialCount
        ]
    }
}

extension UserProfile: DocumentSerializableUser {
    init?(dictionary: [String: Any]) {
        guard let currentUserAuthId = dictionary["currentUserAuthId"] as? String,
            let premiumStatus = dictionary["premiumStatus"] as? Bool,
            let dataCount = dictionary["dataCount"] as? Double,
            let memorialCount = dictionary["memorialCount"] as? Int else { return nil }
        self.init(currentUserAuthId: currentUserAuthId, premiumStatus: premiumStatus, dataCount: dataCount, memorialCount: memorialCount)
    }
}
