//
//  PatternTableViewCell.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/27/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class PatternTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var ruleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
