//
//  StoryTableViewCell.swift
//  GraveYardApp
//
//  Created by Tyler Donohue on 11/4/19.
//  Copyright © 2019 Tyler Donohue. All rights reserved.
//

import UIKit

class StoryTableViewCell: UITableViewCell {
    @IBOutlet weak var storyCellImage: UIImageView!
    @IBOutlet weak var storyCellTitle: UILabel!
    
    var story: [Story]?
    var cellTitle: String?
    var cellImage: UIImage?
    var cellStoryText: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
