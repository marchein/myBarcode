//
//  About+TableView.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

// MARK: - Table View Extension
extension AboutTableViewController {
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "\(NSLocalizedString("Build number", comment: "")): \(myQRcode.buildNumber) (\(getReleaseTitle()))"
        }
        
        if section == 2 {
            return NSLocalizedString("caution_desc", comment: "")
        }
        return nil
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        switch (selectedCell) {
        case contactMailCell:
            sendSupportMail()
            break
        case developerCell:
            openSafariViewControllerWith(url: myQRcode.website)
            break
        case rateCell:
            SKStoreReviewController.requestReview()
            break
        case appStoreCell:
            appStoreAction()
            break
        default:
            break
        }
        selectedCell.setSelected(false, animated: false)
    }
}
