//
//  About+TableView.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import Foundation
import StoreKit
import UIKit

// MARK: - Table View Extension

extension SettingsTableViewController {
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == tableView.numberOfSections - 1 {
            return "\("SETTINGS_DEVELOPER_GREETING".localized) (Version \(myQRcode.versionString))"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let selectedCell = tableView.cellForRow(at: indexPath)
        else {
            return
        }

        switch selectedCell {
        case contactMailCell:
            sendSupportMail()
        case developerCell:
            openSafariViewControllerWith(url: myQRcode.website)
        case rateCell:
            if #available(iOS 14.0, *) {
                SKStoreReviewController.requestReviewInCurrentScene()
            } else {
                SKStoreReviewController.requestReview()
            }
        case appStoreCell:
            appStoreAction()
        default:
            break
        }
        
        selectedCell.setSelected(false, animated: false)
    }
}
