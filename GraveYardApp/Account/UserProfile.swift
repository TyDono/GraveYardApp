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
    var friendIdList: Array<String>
    var friendNameList: Array<String>
    var friendIdRequests: Array<String>
    var friendNameRequest: Array<String>
    var ignoredIdList: Array<String>
    var ignoredNameList: Array<String>
    var memorialCount: Int
    
    var dictionary: [String: Any] {
        return [
            "currentUserAuthId": currentUserAuthId,
            "premiumStatus": premiumStatus,
            "dataCount": dataCount,
            "userIdName": userName,
            "friendList": friendIdList,
            "friendNameList": friendNameList,
            "friendIdRequests": friendIdRequests,
            "friendNameRequest": friendNameRequest,
            "ignoredIdList": ignoredIdList,
            "ignoredNameList": ignoredNameList,
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
            let friendIdList = dictionary["friendIdList"] as? Array<String>,
            let friendNameList = dictionary["friendNameList"] as? Array<String>,
            let friendIdRequests = dictionary["friendIdRequests"] as? Array<String>,
            let friendNameRequest = dictionary["friendNameRequest"] as? Array<String>,
            let ignoredIdList = dictionary["ignoredIdList"] as? Array<String>,
            let ignoredNameList = dictionary["ignoredNameList"] as? Array<String>,
            let memorialCount = dictionary["memorialCount"] as? Int else { return nil }
        self.init(currentUserAuthId: currentUserAuthId, premiumStatus: premiumStatus, dataCount: dataCount, userName: userName, friendIdList: friendIdList, friendNameList: friendNameList, friendIdRequests: friendIdRequests, friendNameRequest: friendNameRequest, ignoredIdList: ignoredIdList, ignoredNameList: ignoredNameList, memorialCount: memorialCount)
    }
}
