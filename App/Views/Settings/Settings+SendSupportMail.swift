//
//  About+SendSupportMail.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import Foundation
import MessageUI
import UIKit
import HeinHelpers

// MARK: - Mail Extension

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func sendSupportMail() {
        let language = Locale.current.languageCode ?? "en"
        let supportMail = language == "de" ? myBarcode.mailAdressDE : myBarcode.mailAdressEN
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("[myBarcode] - Version \(myBarcode.versionString) (Build: \(myBarcode.buildNumber) - \(getReleaseTitle()))")
            mail.setToRecipients([supportMail])
            mail.setMessageBody("support_mail_body".localized, isHTML: false)
            present(mail, animated: true)
        } else {
            print("No mail account configured")
            let mailErrorMessage = "mail_error".localized
            showMessage(title: "Error".localized, message: String(format: mailErrorMessage, supportMail), on: self)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
