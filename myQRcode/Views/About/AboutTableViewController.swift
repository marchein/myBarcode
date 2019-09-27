//
//  AboutViewController.swift
//  myTodo
//
//  Created by Marc Hein on 09.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

class AboutTableViewController: UITableViewController {

    // MARK:- Outlets
    @IBOutlet weak var appVersionCell: UITableViewCell!
    @IBOutlet weak var contactMailCell: UITableViewCell!
    @IBOutlet weak var developerTwitterCell: UITableViewCell!
    @IBOutlet weak var appStoreCell: UITableViewCell!
    @IBOutlet weak var rateCell: UITableViewCell!
    @IBOutlet weak var developerCell: UITableViewCell!
    @IBOutlet weak var appIconIV: UIImageView!
    
    
    // MARK:- Class Attributes
    private var hasTipped = false
    private var currentAppIcon: String?

    
    // MARK: System Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        appVersionCell.detailTextLabel?.text = myQRcode.versionString
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbar.isHidden = true
        navigationController?.navigationBar.prefersLargeTitles = true
        reconfigureView()
    }
    
    fileprivate func reconfigureView() {
        currentAppIcon = UserDefaults.standard.string(forKey: localStoreKeys.currentAppIcon)
        if !myQRcode.appIcons.contains(iconName: currentAppIcon) {
            currentAppIcon = myQRcode.defaultAppIcon
            UserDefaults.standard.set(currentAppIcon, forKey: localStoreKeys.currentAppIcon)
        }
        
        if let appIcon = currentAppIcon {
            appIconIV.image = appIcon == myQRcode.defaultAppIcon ? Bundle.main.icon : UIImage(named: appIcon)
            appIconIV.roundCorners(radius: 6)
        }
        tableView.reloadData()
    }
    
    func appStoreAction() {
        let urlStr = "itms-apps://itunes.apple.com/app/id\(myQRcode.appStoreId)"
        if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func closeModal(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
