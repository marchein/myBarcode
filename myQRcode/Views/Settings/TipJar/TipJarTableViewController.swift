//
//  TipJarTableViewController.swift
//  myTodo
//
//  Created by Marc Hein on 13.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import SafariServices
import StoreKit
import UIKit

class TipJarTableViewController: UITableViewController {
    internal let impact = UIImpactFeedbackGenerator()
    internal var productIDs: [String] = []
    internal var productsArray: [SKProduct?] = []
    internal var selectedProductIndex: Int!
    internal var transactionInProgress = false
    internal var hasData = false

    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)

        setupProducts()
        requestProductInfo()
        navigationController?.displayAnimatedActivityIndicatorView()
    }

    // MARK: - IAP
    fileprivate func setupProducts() {
        productIDs = myQRcodeIAP.allTips
    }

    @IBAction func tipButtonAction(_ sender: UIButton) {
        guard let cell = sender.superview?.superview?.superview as? TipTableViewCell else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
    }
}
