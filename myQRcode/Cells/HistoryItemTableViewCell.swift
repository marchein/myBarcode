//
//  HistoryItemTableViewCell.swift
//  myQRcode
//
//  Created by Marc Hein on 16.08.20.
//  Copyright © 2020 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class HistoryItemTableViewCell: UITableViewCell {

    // MARK: - Properties
    static let Identifier = "HistoryItemTableCell"
    
    // MARK: -
    var historyItem: HistoryItem? {
        didSet {
            guard let historyItem = historyItem else { return }
            
            self.textLabel?.text = historyItem.content
            self.detailTextLabel?.text = "\(historyItem.isoDate) - \(historyItem.isoTime)"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
