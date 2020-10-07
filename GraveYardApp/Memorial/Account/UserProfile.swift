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
    var premiumStatus: Int
    var dataCount: Double
    var userName: String
    var friendList: Array<String>
    var friendRequests: Array<String>
    var blockedList: Array<String>
    var memorialCount: Int
    
    var dictionary: [String: Any] {
        return [
            "currentUserAuthId": currentUserAuthId,
            "premiumStatus": premiumStatus,
            "dataCount": dataCount,
            "userName": userName,
            "friendList": friendList,
            "friendRequests": friendRequests,
            "blockedList": blockedList,
            "memorialCount": memorialCount
        ]
    }
}

extension UserProfile: DocumentSerializableUser {
    init?(dictionary: [String: Any]) {
        guard let currentUserAuthId = dictionary["currentUserAuthId"] as? String,
            let premiumStatus = dictionary["premiumStatus"] as? Int,
            let dataCount = dictionary["dataCount"] as? Double,
            let userName = dictionary["userName"] as? String,
            let friendList = dictionary["friendList"] as? Array<String>,
            let friendRequests = dictionary["friendRequests"] as? Array<String>,
            let blockedList = dictionary["blockedList"] as? Array<String>,
            let memorialCount = dictionary["memorialCount"] as? Int else { return nil }
        self.init(currentUserAuthId: currentUserAuthId, premiumStatus: premiumStatus, dataCount: dataCount, userName: userName, friendList: friendList, friendRequests: friendRequests, blockedList: blockedList, memorialCount: memorialCount)
    }
}
