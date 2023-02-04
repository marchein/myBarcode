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
extension SettingsTableViewController {

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == tableView.numberOfSections - 1 {
            return "\(NSLocalizedString("SETTINGS_DEVELOPER_GREETING", comment: "")) (Version \(myQRcode.versionString) - Build \(myQRcode.buildNumber))"
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
            if #available(iOS 14.0, *) {
                SKStoreReviewController.requestReviewInCurrentScene()
            } else {
                SKStoreReviewController.requestReview()
            }
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
