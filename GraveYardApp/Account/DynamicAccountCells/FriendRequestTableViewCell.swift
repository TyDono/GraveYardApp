//
//  FriendRequestTableViewCell.swift
//  Remembrances
//
//  Created by Tyler Donohue on 10/6/20.
//  Copyright © 2020 Tyler Donohue. All rights reserved.
//

import UIKit

class FriendRequestTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var friendRequestNameLabel: UILabel!
    
    var friendRequestId: String?
    
    // MARK: - Propeties

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
