//
//  TipTableViewCell.swift
//  myBarcode
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import Foundation
import UIKit

class TipTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let Identifier = "TipTableViewCell"
    
    @IBOutlet weak var tipTitle: UILabel!
    @IBOutlet weak var tipDesc: UILabel!
    @IBOutlet weak var purchaseButton: BorderedButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
