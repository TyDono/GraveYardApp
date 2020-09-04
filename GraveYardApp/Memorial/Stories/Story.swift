//
//  Story.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/30/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import Foundation
import UIKit

protocol IdentifiableStory {
    var id: String? { get set }
}

protocol DocumentSerializableStory {
    init?(dictionary: [String: Any])
}

struct Story {
    
    var creatorId: String
    var graveId: String
    var storyId: String
    var storyBodyText: String
    var storyTitle: String
    var storyImageArray: [String]
    var storyImageId1: String
    var storyImageId2: String
    var storyImageId3: String
    var storyImageId4: String
    var storyImageId5: String
    var storyImageId6: String
    
    var dictionary: [String: Any] {
        return [
            "creatorId": creatorId,
            "graveId": graveId,
            "storyId": storyId,
            "storyBodyText": storyBodyText,
            "storyTitle": storyTitle,
            "storyImageArray": storyImageArray,
            "storyImageId1": storyImageId1,
            "storyImageId2": storyImageId2,
            "storyImageId3": storyImageId3,
            "storyImageId4": storyImageId4,
            "storyImageId5": storyImageId5,
            "storyImageId6": storyImageId6
            
        ]
    }
}

extension Story: DocumentSerializableStory {
    init?(dictionary: [String: Any]) {
        guard let creatorId = dictionary["creatorId"] as? String,
            let graveId = dictionary["graveId"] as? String,
            let storyId = dictionary["storyId"] as? String,
            let storyBodyText = dictionary["storyBodyText"] as? String,
            let storyTitle = dictionary["storyTitle"] as? String,
            let storyImageArray = dictionary["storyImageArray"] as? [String],
            let storyImageId1 = dictionary["storyImageId1"] as? String,
            let storyImageId2 = dictionary["storyImageId2"] as? String,
            let storyImageId3 = dictionary["storyImageId3"] as? String,
            let storyImageId4 = dictionary["storyImageId4"] as? String,
            let storyImageId5 = dictionary["storyImageId5"] as? String,
            let storyImageId6 = dictionary["storyImageId6"] as? String else {return nil}
        self.init(creatorId: creatorId, graveId: graveId, storyId: storyId, storyBodyText: storyBodyText, storyTitle: storyTitle, storyImageArray: storyImageArray, storyImageId1: storyImageId1, storyImageId2: storyImageId2, storyImageId3: storyImageId3, storyImageId4: storyImageId4, storyImageId5: storyImageId5, storyImageId6: storyImageId6)
    }
    
}
