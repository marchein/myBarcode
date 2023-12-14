//
//  HistoryItemTableViewCell.swift
//  myBarcode
//
//  Created by Marc Hein on 16.08.20.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

class HistoryItemTableViewCell: UITableViewCell {

    // MARK: - Properties
    static let Identifier = "HistoryItemTableCell"
    
    // MARK: - Data
    var historyItem: HistoryItem? {
        didSet {
            guard let historyItem = historyItem else { return }
            
            let type = historyItem.type ?? myBarcode.codeValues[.QR] ?? "N/A"
            self.textLabel?.text = historyItem.content
            let usedTemplate = historyItem.templateName != nil ? ",  \("TEMPLATE".localized): \(historyItem.templateName!)" : ""
            self.detailTextLabel?.text = "\(historyItem.isoDate) - \(historyItem.isoTime) (\(type)\(usedTemplate))"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textLabel?.numberOfLines = 3
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
