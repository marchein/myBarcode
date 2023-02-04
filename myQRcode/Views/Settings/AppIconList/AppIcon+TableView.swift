//
//  AppIcon+TableView.swift
//  myQRcode
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Table View
extension AppIconTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96.0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myQRcode.appIcons.count()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIcon = myQRcode.appIcons.getIcon(for: indexPath.row)?.iconName
        DispatchQueue.main.async(execute: { () -> Void in
            UserDefaults.standard.set(selectedIcon ?? myQRcode.defaultAppIcon, forKey: localStoreKeys.currentAppIcon)
            self.setSelectedImage(key: selectedIcon, cell: tableView.cellForRow(at: indexPath))
            self.tableView.reloadData()
        })
        changeIcon(to: selectedIcon)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AppIconTableViewCell.Identifier, for: indexPath) as! AppIconTableViewCell
        configureCell(cell: cell, on: indexPath)
        return cell
    }

    func configureCell(cell: AppIconTableViewCell, on indexPath: IndexPath) {
        cell.accessoryType = .none
        let imageOfCurrentCell = myQRcode.appIcons.getIcon(for: indexPath.row)
        setSelectedImage(key: imageOfCurrentCell?.iconName, cell: cell)
        cell.appIcon.image = getAppIconFor(value: imageOfCurrentCell?.iconName)
        cell.setTitle(title: imageOfCurrentCell?.iconTitle)
    }
}
