//
//  userReports.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 1/9/20.
//  Copyright © 2020 Tyler Donohue. All rights reserved.
//

import Foundation

protocol IdentifiableUserReports {
    var id: String? { get set }
}

protocol DocumentSerializableUserReports {
    init?(dictionary: [String: Any])
}

struct userReport {
    
    var reporterCreatorId: String
    var reason: String
    var creatorId: String
    var graveId: String
    var storyId: String
    
    var dictionary: [String: Any] {
        return [
            "reporterCreatorId": reporterCreatorId,
            "reason": reason,
            "creatorId": creatorId,
            "graveId": graveId,
            "storyId": storyId
        ]
    }
}

extension userReport: DocumentSerializableUserReports {
    init?(dictionary: [String: Any]) {
        guard let reporterCreatorId = dictionary["reporterCreatorId"] as? String,
            let reason = dictionary["reason"] as? String,
            let creatorId = dictionary["creatorId"] as? String,
            let graveId = dictionary["graveId"] as? String,
            let storyId = dictionary["storyId"] as? String else {return nil}
        self.init(reporterCreatorId: reporterCreatorId, reason: reason, creatorId: creatorId, graveId: graveId, storyId: storyId)
    }
    
}
