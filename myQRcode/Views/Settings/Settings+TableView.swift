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
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Version \(myQRcode.versionString) (Build: \(myQRcode.buildNumber))"
        }
        if section == tableView.numberOfSections - 1 {
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
            openSafariViewControllerWith(url: myQRcode.website)
            myQRcodeMatomo.track(action: myQRcodeMatomo.settingsAction, name: myQRcodeMatomo.settingsAboutAction)
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
