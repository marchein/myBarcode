//
//  SettingsDefaultCodeTableViewController.swift
//  Barcode Scanner & Generator
//
//  Created by Marc Hein on 10.12.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

class SettingsDefaultCodeTableViewController: UITableViewController {
    
    var selectedDefaultCode: PossibleCodes {
        get {
            return PossibleCodes(rawValue: UserDefaults.standard.integer(forKey: localStoreKeys.defaultCode)) ?? .QR
        }
        
        set {
            let selectedDefaultCode = newValue.rawValue

            UserDefaults.standard.set(selectedDefaultCode, forKey: localStoreKeys.defaultCode)
            UserDefaults.standard.synchronize()
            var indexPaths: [IndexPath] = []
            for i in 0..<self.tableView(self.tableView, numberOfRowsInSection: tableView.numberOfSections) {
                if i != selectedDefaultCode {
                    let indexPath = IndexPath(row: i, section: 0)
                    indexPaths.append(indexPath)
                    let cell = self.tableView(self.tableView, cellForRowAt: indexPath)
                    cell.accessoryType = .none
                }
            }
            indexPaths.append(IndexPath(row: selectedDefaultCode, section: 0))
            self.tableView.reloadRows(at: indexPaths, with: .automatic)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myBarcodeMatomo.track(action: myBarcodeMatomo.settingsAction, name: myBarcodeMatomo.settingsDefaultCodeAction)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myBarcode.codeValues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let row = indexPath.row
        
        guard let codeForRow = PossibleCodes(rawValue: row), let cellLabel = myBarcode.codeValues[codeForRow] else {
            fatalError()
        }
        
        cell.textLabel?.text = cellLabel
        cell.accessoryType = selectedDefaultCode == codeForRow ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let codeOption = PossibleCodes(rawValue: indexPath.row) else {
            fatalError()
        }
        self.selectedDefaultCode = codeOption
        myBarcodeMatomo.track(action: myBarcodeMatomo.settingsAction, name: myBarcodeMatomo.settingsDefaultCodeSetAction, number: NSNumber(value: indexPath.row))
    }
}
