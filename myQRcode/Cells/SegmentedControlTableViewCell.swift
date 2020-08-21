//
//  SegmentedControlTableViewCell.swift
//  myQRcode
//
//  Created by Marc Hein on 21.08.20.
//  Copyright © 2020 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class SegmentedControlTableViewCell: UITableViewCell {
    
    static let Identifier = "segmentedControlCell"

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var options: [String]? {
        didSet {
            for option in options! {
                self.segmentedControl.insertSegment(withTitle: option, at: self.segmentedControl.numberOfSegments, animated: true)
            }
            self.segmentedControl.selectedSegmentIndex = self.segmentedControl.numberOfSegments - 1 
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.segmentedControl.removeAllSegments()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
