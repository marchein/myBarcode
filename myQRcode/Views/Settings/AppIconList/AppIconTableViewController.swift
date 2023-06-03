//
//  AppIconTableViewController.swift
//  myQRcode
//
//  Created by Marc Hein on 15.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

class AppIconTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        myQRcodeMatomo.track(action: myQRcodeMatomo.settingsAction, name: myQRcodeMatomo.settingsAppIconAction)
    }
    
    // MARK:- Image functions
    internal func getAppIconFor(value: String?) -> UIImage? {
        if let imageName = value {
            return UIImage(named: imageName)
        }
        return Bundle.main.icon
    }
    
    internal func changeIcon(to name: String?) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        
        UIApplication.shared.setAlternateIconName(name) { (error) in
            if let error = error {
                fatalError("Error: \(error)")
            }
        }
    }
    
    internal func setSelectedImage(key: String?, cell: UITableViewCell?) {
        let currentAppIcon = UserDefaults.standard.string(forKey: localStoreKeys.currentAppIcon)
        if key ?? myQRcode.defaultAppIcon == currentAppIcon {
            cell?.accessoryType = .checkmark
        }
    }
}
