//
//  BlockedListTableViewCell.swift
//  Remembrances
//
//  Created by Tyler Donohue on 10/6/20.
//  Copyright © 2020 Tyler Donohue. All rights reserved.
//

import UIKit

class IgnoreListTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var ignoreNameLabel: UILabel!
    
    var ignoreId: String?
    
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
