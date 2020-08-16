//
//  ScanResultViewController.swift
//  myQRcode
//
//  Created by Marc Hein on 28.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class ScanResultViewController: UIViewController, HistoryItemDelegate {
    var codeResult: String?
    
    @IBOutlet weak var resultTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        resultTextView.text = codeResult
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "resetView"), object: nil)
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true) {
            if let scanVC = self.presentingViewController as? ScanViewController {
                scanVC.resetScanner()
            }
        }
    }
    
    func userSelectedHistoryItem(item: HistoryItem) {
        self.resultTextView.text = item.content
    }

}
