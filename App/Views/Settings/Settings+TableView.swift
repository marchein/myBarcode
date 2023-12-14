//
//  About+TableView.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Table View Extension

extension SettingsTableViewController {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Version \(myBarcode.versionString) (Build: \(myBarcode.buildNumber))"
        } else if section == 1 {
            return "SETTINGS_DISABLE_HISTORY_HINT".localized
        } else if section == tableView.numberOfSections - 1 {
            return "SETTINGS_DEVELOPER_GREETING".localized
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
            openSafariViewControllerWith(url: myBarcode.website)
            myBarcodeMatomo.track(action: myBarcodeMatomo.settingsAction, name: myBarcodeMatomo.settingsAboutAction)
        case rateCell:
            rateAction()
        case appStoreCell:
            appStoreAction()
        default:
            break
        }
        
        selectedCell.setSelected(false, animated: false)
    }
}
