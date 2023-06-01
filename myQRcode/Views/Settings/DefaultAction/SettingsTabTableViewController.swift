//
//  SettingsTabTableViewController.swift
//  myQRcode
//
//  Created by Marc Hein on 12.02.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit
import HeinHelpers

class SettingsTabTableViewController: UITableViewController {
    var selectedTab: TabOption {
        get {
            return TabOption(rawValue: UserDefaults.standard.integer(forKey: localStoreKeys.defaultTab)) ?? .GENERATE
        }
        
        set {
            let selectedTabIndex = newValue.rawValue

            UserDefaults.standard.set(selectedTabIndex, forKey: localStoreKeys.defaultTab)
            UserDefaults.standard.synchronize()
            var indexPaths: [IndexPath] = []
            for i in 0..<self.tableView(self.tableView, numberOfRowsInSection: tableView.numberOfSections) {
                if i != selectedTabIndex {
                    let indexPath = IndexPath(row: i, section: 0)
                    indexPaths.append(indexPath)
                    let cell = self.tableView(self.tableView, cellForRowAt: indexPath)
                    cell.accessoryType = .none
                }
            }
            //MensaplanApp.getMainVC()?.refreshAction(self)
            indexPaths.append(IndexPath(row: selectedTabIndex, section: 0))
            
            self.tableView.reloadRows(at: indexPaths, with: .automatic)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myQRcode.tabValues.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "TAB_SELECTION_HEADER".localized
     }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "TAB_SELECTION_FOOTER".localized
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let row = indexPath.row
        
        guard let tabForRow = TabOption(rawValue: row), let cellLabel = myQRcode.tabValues[tabForRow] else {
            fatalError()
        }
        
        cell.textLabel?.text = cellLabel
        cell.accessoryType = selectedTab == tabForRow ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tabOption = TabOption(rawValue: indexPath.row) else {
            fatalError()
        }
        self.selectedTab = tabOption
    }
}
