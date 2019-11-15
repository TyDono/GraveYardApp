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
    var currentAuthId: String
    var premiumStatus: Bool
    
    var dictionary: [String: Any] {
        return [
            "currentAuthId": currentAuthId,
            "premiumStatus": premiumStatus
        ]
    }
}

extension UserProfile: DocumentSerializableUser {
    init?(dictionary: [String: Any]) {
        guard let currentAuthId = dictionary["currentAuthId"] as? String,
            let premiumStatus = dictionary["premiumStatus"] as? Bool else { return nil }
        self.init(currentAuthId: currentAuthId, premiumStatus: premiumStatus)
    }
}
