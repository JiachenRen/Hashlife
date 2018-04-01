//
//  SegmentedControlTableViewCell.swift
//  Hashlife
//
//  Created by Jiachen Ren on 7/28/17.
//  Copyright © 2017 Jiachen. All rights reserved.
//

import UIKit

class SegmentedControlTableViewCell: UITableViewCell, NamedTableViewCell {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var segmentedControlChanged: ((Int, String) -> ())?
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        self.segmentedControlChanged?(sender.selectedSegmentIndex, sender.titleForSegment(at: sender.selectedSegmentIndex)!)
    }
}
