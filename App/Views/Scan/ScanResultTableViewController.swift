//
//  ScaneResultTableViewController.swift
//  myBarcode
//
//  Created by Marc Hein on 16.08.20.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

class ScanResultTableViewController: UITableViewController {
    var historyItem: HistoryItem!
    var scanVC: ScanViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.presentationController?.delegate = self
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true) {
            self.resetScannerInScanVC()
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.Identifier, for: indexPath) as! TextViewTableViewCell
        cell.textView?.text = self.historyItem.content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let scannedCodeType = myBarcode.codeStrings[historyItem.type ?? "QR"] ?? .QR
        let selectedCodeName = myBarcode.codeValues[scannedCodeType] ?? myBarcode.codeValues[.QR]!
        return "\("SCANNED".localized) \(selectedCodeName) \("CODE".localized)"
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "\("date_scanning".localized): \(self.historyItem.isoDate) - \(self.historyItem.isoTime)"
    }
    
    private func resetScannerInScanVC() {
        if let scanVC = self.scanVC {
            scanVC.resetScanner()
        }
    }
}

extension ScanResultTableViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.dismiss(presentationController)
    }
}
