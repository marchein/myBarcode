//
//  AboutViewController.swift
//  myTodo
//
//  Created by Marc Hein on 09.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import CoreData
import SafariServices
import UIKit

class SettingsTableViewController: UITableViewController {
    // MARK: - Outlets

    @IBOutlet var selectedTabName: UILabel!
    @IBOutlet var contactMailCell: UITableViewCell!
    @IBOutlet var developerTwitterCell: UITableViewCell!
    @IBOutlet var appStoreCell: UITableViewCell!
    @IBOutlet var rateCell: UITableViewCell!
    @IBOutlet var developerCell: UITableViewCell!
    @IBOutlet var appIconIV: UIImageView!
    
    // MARK: - Class Attributes

    private var hasTipped = false
    private var currentAppIcon: String?

    // MARK: System Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        myQRcodeMatomo.track(action: myQRcodeMatomo.settingsAction, name: myQRcodeMatomo.settingsOpenAction)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbar.isHidden = true
        navigationController?.navigationBar.prefersLargeTitles = true
        reconfigureView()
    }
    
    fileprivate func reconfigureView() {
        configureNavigator()
        currentAppIcon = UserDefaults.standard.string(forKey: localStoreKeys.currentAppIcon)
        if !myQRcode.appIcons.contains(iconName: currentAppIcon) {
            currentAppIcon = myQRcode.defaultAppIcon
            UserDefaults.standard.set(currentAppIcon, forKey: localStoreKeys.currentAppIcon)
            UserDefaults.standard.synchronize()
        }
        
        self.updateCurrentTab()
        
        if let appIcon = currentAppIcon {
            appIconIV.image = appIcon == myQRcode.defaultAppIcon ? Bundle.main.icon : UIImage(named: appIcon)
            appIconIV.layer.borderWidth = 1.0
            appIconIV.layer.borderColor = UIColor.lightGray.cgColor
            appIconIV.roundCorners(radius: 6)
        }
        tableView.reloadData()
    }
    
    func updateCurrentTab() {
        guard let resultValue = TabOption(rawValue: UserDefaults.standard.integer(forKey: localStoreKeys.defaultTab)) else {
            fatalError()
        }
        self.selectedTabName.text = myQRcode.tabValues[resultValue]
    }
    
    private func configureNavigator() {
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController.navigationBar.sizeToFit()
    }
    
    func appStoreAction() {
        let urlStr = "itms-apps://itunes.apple.com/app/id\(myQRcode.appStoreId)"
        if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        myQRcodeMatomo.track(action: myQRcodeMatomo.settingsAction, name: myQRcodeMatomo.settingsAppStoreAction)
    }
    
    @IBAction func closeModal(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
