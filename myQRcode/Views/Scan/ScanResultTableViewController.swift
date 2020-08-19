//
//  ScaneResultTableViewController.swift
//  myQRcode
//
//  Created by Marc Hein on 16.08.20.
//  Copyright © 2020 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class ScanResultTableViewController: UITableViewController {
    var historyItem: HistoryItem!
    var scanVC: ScanViewController?
    
    @IBOutlet weak var resultTextView: UILabel!
    
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
        let cell = UITableViewCell()
        cell.textLabel?.text = self.historyItem.content
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "\(NSLocalizedString("date_scanning", comment: "")): \(self.historyItem.isoDate) - \(self.historyItem.isoTime)"
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
