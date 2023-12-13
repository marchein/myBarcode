//
//  SegmentedControlTableViewCell.swift
//  myBarcode
//
//  Created by Marc Hein on 21.08.20.
//  Copyright © 2023 Marc Hein. All rights reserved.
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
    
    var selectedIndex: Int? {
        didSet {
            if let optionsCount = options?.count, selectedIndex ?? 0 < optionsCount {
                segmentedControl.selectedSegmentIndex = selectedIndex ?? self.segmentedControl.numberOfSegments - 1
            }
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
