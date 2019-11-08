//
//  Story.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 10/30/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

protocol IdentifiableStory {
    var id: String? { get set }
}

protocol DocumentSerializableStory {
    init?(dictionary: [String: Any])
}

struct Story {
    
    var graveId: String
    var storyId: String
    var storyBody: String
    var storyTitle: String
    var storyImage: String
    
    var dictionary: [String: Any] {
        return [
            "graveId": graveId,
            "storyId": storyId,
            "storyBody": storyBody,
            "storyTitle": storyTitle,
            "storyImage": storyImage
        ]
    }
}

extension Story: DocumentSerializableStory {
    init?(dictionary: [String: Any]) {
        guard let graveId = dictionary["graveId"] as? String,
            let storyId = dictionary["storyId"] as? String,
            let storyBody = dictionary["storyBody"] as? String,
            let storyTitle = dictionary["storyTitle"] as? String,
            let storyImage = dictionary["storyImage"] as? String else {return nil}
        self.init(graveId: graveId, storyId: storyId, storyBody: storyBody, storyTitle: storyTitle, storyImage: storyImage)
    }
    
}
