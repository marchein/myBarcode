//
//  GenerateViewController+TableView.swift
//  myBarcode
//
//  Created by Marc Hein on 19.03.23.
//  Copyright © 2023 Marc Hein Webdesign. All rights reserved.
//

import UIKit

extension GenerateViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resignTextViewFirstResponder()
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        
        // Set height for selection row to zero, as it was simpler to just "hide" it instead of really removing the cell from the table
        if section == 1 && row == 0 && hideCodeTypeSelector {
            return 0
        } else if section == 2 && row == 0 && (selectedCodeType == .PDF417 || selectedCodeType == .CODE128 ) {
            return 150
        }
        
        
        return UITableView.automaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return CGFloat.leastNonzeroMagnitude
        }
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            let selectedCodeName = myBarcode.codeValues[selectedCodeType] ?? myBarcode.codeValues[.QR]!
            return "\("GENERATED".localized) \(selectedCodeName) \("CODE".localized)"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return CGFloat.leastNonzeroMagnitude
        }
        
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 ||  section == 2 || (section == 3 && usedTemplate != nil) {
            return 2
        }
                
        return 1
    }
}
