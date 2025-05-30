//
//  TipJar+TableView.swift
//  myTodo
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Table View
extension TipJarTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return productsArray.count > 0 ? productsArray.count : 1
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: Cells.TipIntroCell)
            cell.textLabel?.text = "\("tip_greeting".localized) 😌"
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.lineBreakMode = .byWordWrapping
            cell.detailTextLabel?.text = "tip_desc".localized
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TipTableViewCell.Identifier, for: indexPath) as! TipTableViewCell
            if productsArray.count > indexPath.row {
                if let product = productsArray[indexPath.row] {
                    cell.tipTitle.text = product.localizedTitle
                    // cell.tipDesc.text = product.localizedDescription
                    cell.tipDesc.text = nil
                    cell.purchaseButton.isHidden = false
                    cell.purchaseButton.setTitle(product.localizedPrice, for: .normal)
                }
            } else {
                cell.tipTitle.text = "no_tips".localized
                cell.tipDesc.text = "no_tips_desc".localized
                cell.purchaseButton.isHidden = true
                cell.tipDesc.isHidden = false
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 140.0
        } else {
            return hasData ? 68.0 : 100.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            selectedProductIndex = indexPath.row
            startTransaction()
        }
        
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }
}
