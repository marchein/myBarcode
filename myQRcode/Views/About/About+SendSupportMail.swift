//
//  About+SendSupportMail.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import MessageUI
import UIKit

// MARK:- Mail Extension
extension AboutTableViewController: MFMailComposeViewControllerDelegate {
    func sendSupportMail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("[myQRcode] - Version \(myQRcode.versionString) (Build: \(myQRcode.buildNumber) - \(getReleaseTitle()))")
            mail.setToRecipients([myQRcode.mailAdress])
            mail.setMessageBody(NSLocalizedString("support_mail_body", comment: ""), isHTML: false)
            present(mail, animated: true)
        } else {
            print("No mail account configured")
            showLinksClicked(url: myQRcode.supportPage)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
