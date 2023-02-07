//
//  AppIconTableViewCell.swift
//  myQRcode
//
//  Created by Marc Hein on 23.09.19.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

class AppIconTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let Identifier = "AppIconTableViewCell"

    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        appIcon.dropShadow()
        appIcon.roundCorners(radius: 12)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTitle(title: String?) {
        titleLabel.text = title
    }

}
