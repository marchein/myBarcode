//
//  PrivacyTableViewController.swift
//  myBarcode
//
//  Created by Marc Hein on 02.06.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit
import MatomoTracker

class PrivacyTableViewController: UITableViewController {

    @IBOutlet var privacyNoticeCell: UITableViewCell!
    @IBOutlet var whatIsMatomoCell: UITableViewCell!
    @IBOutlet var optOutCell: UITableViewCell!
    @IBOutlet var optOutSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        optOutSwitch.isOn = !MatomoTracker.shared.isOptedOut
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let selectedCell = tableView.cellForRow(at: indexPath)
        else {
            return
        }
        
        let langCode = Locale.current.languageCode
        switch selectedCell {
        case privacyNoticeCell:
            openSafariViewControllerWith(url: langCode == "de" ? myBarcode.privacyNoticeDE : myBarcode.privacyNoticeEN)
            myBarcodeMatomo.track(action: myBarcodeMatomo.settingsAction, name: myBarcodeMatomo.settingsPrivacyNoticeAction)
        case whatIsMatomoCell:
            openSafariViewControllerWith(url: myBarcode.matomoWebsite)
            myBarcodeMatomo.track(action: myBarcodeMatomo.settingsAction, name: myBarcodeMatomo.settingsMatomoAboutAction)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func optOutSwitchChanged(_ sender: UISwitch) {
        myBarcodeMatomo.track(action: myBarcodeMatomo.settingsAction, name: myBarcodeMatomo.settingsMatomoOptOutAction, number: NSNumber(value: MatomoTracker.shared.isOptedOut ? 1 : 0))
        MatomoTracker.shared.dispatch()
        MatomoTracker.shared.isOptedOut = !sender.isOn
    }
}
