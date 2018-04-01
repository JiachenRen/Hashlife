//
//  ToggleTableViewCell.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/28/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class ToggleTableViewCell: UITableViewCell, NamedTableViewCell {

    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    var switchToggled: ((Bool) -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print(self.switch)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        self.switchToggled?(sender.isOn)
    }
    

}

protocol NamedTableViewCell {
    var nameLabel: UILabel! { get set }
}
