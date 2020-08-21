//
//  NoItemsView.swift
//  myQRcode
//
//  Created by Marc Hein on 21.08.20.
//  Copyright © 2020 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class NoItemsView: UIView {

    @IBOutlet weak var errorIcon: UIImageView!
    @IBOutlet weak var noEntrysLabel: UILabel!
    var category: HistoryCategory? {
        didSet {
            if #available(iOS 13.0, *) {
                errorIcon.image = UIImage(systemName: "exclamationmark.circle")
            }
            noEntrysLabel.text = self.category == HistoryCategory.generate ? NSLocalizedString("no_generate_history", comment: "") : NSLocalizedString("no_scan_history", comment: "")
        }
    }
}
