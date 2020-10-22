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
    var userAuthId: String
    var premiumStatus: Int
    var dataCount: Double
    var userName: String
    var friendIdList: Array<String>
    var friendNameList: Array<String>
    var friendIdRequestList: Array<String>
    var friendNameRequestList: Array<String>
    var ignoredIdList: Array<String>
    var ignoredNameList: Array<String>
    var memorialCount: Int
    
    var dictionary: [String: Any] {
        return [
            "userAuthId": userAuthId,
            "premiumStatus": premiumStatus,
            "dataCount": dataCount,
            "userName": userName,
            "friendIdList": friendIdList,
            "friendNameList": friendNameList,
            "friendIdRequestList": friendIdRequestList,
            "friendNameRequestList": friendNameRequestList,
            "ignoredIdList": ignoredIdList,
            "ignoredNameList": ignoredNameList,
            "memorialCount": memorialCount
        ]
    }
}

extension UserProfile: DocumentSerializableUser {
    init?(dictionary: [String: Any]) {
        guard let userAuthId = dictionary["userAuthId"] as? String,
            let premiumStatus = dictionary["premiumStatus"] as? Int,
            let dataCount = dictionary["dataCount"] as? Double,
            let userName = dictionary["userName"] as? String,
            let friendIdList = dictionary["friendIdList"] as? Array<String>,
            let friendNameList = dictionary["friendNameList"] as? Array<String>,
            let friendIdRequestList = dictionary["friendIdRequestList"] as? Array<String>,
            let friendNameRequestList = dictionary["friendNameRequestList"] as? Array<String>,
            let ignoredIdList = dictionary["ignoredIdList"] as? Array<String>,
            let ignoredNameList = dictionary["ignoredNameList"] as? Array<String>,
            let memorialCount = dictionary["memorialCount"] as? Int else { return nil }
        self.init(userAuthId: userAuthId, premiumStatus: premiumStatus, dataCount: dataCount, userName: userName, friendIdList: friendIdList, friendNameList: friendNameList, friendIdRequestList: friendIdRequestList, friendNameRequestList: friendNameRequestList, ignoredIdList: ignoredIdList, ignoredNameList: ignoredNameList, memorialCount: memorialCount)
    }
}
