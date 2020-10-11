//
//  FriendListTableViewCell.swift
//  Remembrances
//
//  Created by Tyler Donohue on 10/11/20.
//  Copyright © 2020 Tyler Donohue. All rights reserved.
//

import UIKit

class FriendListTableViewCell: UITableViewCell {

    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var removeFriendButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func removeFriendButtonWasTapped(_ sender: UIButton) {
    }
}
