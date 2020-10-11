//
//  FriendListDynamicTableViewCell.swift
//  Remembrances
//
//  Created by Tyler Donohue on 10/11/20.
//  Copyright © 2020 Tyler Donohue. All rights reserved.
//

import UIKit

class FriendListDynamicTableViewCell: UITableViewCell {
    
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var removeFriendButton: UIButton!
    
    var friendId: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func removeFriendButonWasTapped(_ sender: Any) {
    }
    
}
