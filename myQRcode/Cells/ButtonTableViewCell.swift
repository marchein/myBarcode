//
//  ButtonTableViewCell.swift
//  myQRcode
//
//  Created by Marc Hein on 21.08.20.
//  Copyright © 2020 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let reuseIdentifier = "ButtonTableViewCell"
    
    @IBOutlet weak var buttonLabel: UILabel!
    
    var isEnabled: Bool = true {
        didSet {
            self.selectionStyle = self.isEnabled ? UITableViewCell.SelectionStyle.default: UITableViewCell.SelectionStyle.none;
            self.isUserInteractionEnabled = self.isEnabled
            self.buttonLabel.textColor = self.isEnabled ? UIColor.systemBlue : UIColor.lightGray
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
