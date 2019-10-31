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
    
    var story: String
    var storyTitle: String
    var storyImage: String
    
    var dictionary: [String: Any] {
        return [
            "story": story,
            "storyTitle": storyTitle,
            "storyImage": storyImage
        ]
    }
}

extension Story: DocumentSerializableStory {
    init?(dictionary: [String: Any]) {
        guard let story = dictionary["story"] as? String,
            let storyTitle = dictionary["storyTitle"] as? String,
            let storyImage = dictionary["storyImage"] as? String else {return nil}
        self.init(story: story, storyTitle: storyTitle, storyImage: storyImage)
    }
    
}
