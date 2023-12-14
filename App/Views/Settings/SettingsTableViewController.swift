//
//  AboutViewController.swift
//  myTodo
//
//  Created by Marc Hein on 09.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import CoreData
import SafariServices
import StoreKit
import UIKit

class SettingsTableViewController: UITableViewController, UIAdaptivePresentationControllerDelegate {
    // MARK: - Outlets

    @IBOutlet var selectedTabName: UILabel!
    @IBOutlet var contactMailCell: UITableViewCell!
    @IBOutlet var developerTwitterCell: UITableViewCell!
    @IBOutlet var selectedDefaultCode: UILabel!
    // If only the selected Code type should be displayed on the start page
    @IBOutlet weak var showOnlyDefaultCodeSwitch: UISwitch!
    @IBOutlet weak var disableHistorySwitch: UISwitch!
    @IBOutlet var appStoreCell: UITableViewCell!
    @IBOutlet var rateCell: UITableViewCell!
    @IBOutlet var developerCell: UITableViewCell!
    
    // MARK: - Class Attributes

    private var hasTipped = false

    // MARK: System Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.presentationController?.delegate = self
        myBarcodeMatomo.track(action: myBarcodeMatomo.settingsAction, name: myBarcodeMatomo.settingsOpenAction)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbar.isHidden = true
        navigationController?.navigationBar.prefersLargeTitles = true
        reconfigureView()
    }
    
    fileprivate func reconfigureView() {
        configureNavigator()
        
        updateCurrentTab()
        updateDefaultCode()
        updateHistoryDisabled()
        
        tableView.reloadData()
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        let generateVC = myBarcode.getGenerateVC()
        generateVC?.updateViewFromSettings()
    }
    
    func updateCurrentTab() {
        guard let resultValue = TabOption(rawValue: UserDefaults.standard.integer(forKey: localStoreKeys.defaultTab)) else {
            fatalError()
        }
        self.selectedTabName.text = myBarcode.tabValues[resultValue]
    }
    
    func updateDefaultCode() {
        let showOnlyDefault = UserDefaults.standard.bool(forKey: localStoreKeys.showOnlyDefaultCode)
        self.showOnlyDefaultCodeSwitch.isOn = showOnlyDefault
        
        let resultValue = PossibleCodes(rawValue: UserDefaults.standard.integer(forKey: localStoreKeys.defaultCode)) ?? PossibleCodes.QR
        self.selectedDefaultCode.text = myBarcode.codeValues[resultValue]
    }
        
    @IBAction func defaultCodeSwitchChanged(_ sender: Any) {
        let switchObj = sender as? UISwitch, value = switchObj?.isOn ?? false
        UserDefaults.standard.set(value, forKey: localStoreKeys.showOnlyDefaultCode)
        UserDefaults.standard.synchronize()
        myBarcodeMatomo.track(action: myBarcodeMatomo.settingsAction, name: myBarcodeMatomo.settingsHideNonDefaultCodeSetAction, number: value ? 1 : 0)
    }
    
    func updateHistoryDisabled() {
        let historyDisabled = UserDefaults.standard.bool(forKey: localStoreKeys.historyDisabled)
        self.disableHistorySwitch.isOn = historyDisabled
    }
    
    @IBAction func disableHistorySwitchChanged(_ sender: Any) {
        let switchObj = sender as? UISwitch, value = switchObj?.isOn ?? false
        UserDefaults.standard.set(value, forKey: localStoreKeys.historyDisabled)
        UserDefaults.standard.synchronize()
        myBarcodeMatomo.track(action: myBarcodeMatomo.settingsAction, name: myBarcodeMatomo.settingsDisableHistorySetAction, number: value ? 1 : 0)
    }
    
    private func configureNavigator() {
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController.navigationBar.sizeToFit()
    }
    
    func rateAction() {
        myBarcodeMatomo.track(action: myBarcodeMatomo.settingsAction, name: myBarcodeMatomo.settingsReviewAction)
        var components = URLComponents(url: URL(string: myBarcode.appStoreLink)!, resolvingAgainstBaseURL: false)
        components?.queryItems = [
          URLQueryItem(name: "action", value: "write-review")
        ]
        guard let writeReviewURL = components?.url, UIApplication.shared.canOpenURL(writeReviewURL) else {
            SKStoreReviewController.requestReviewInCurrentScene()
          return
        }
        UIApplication.shared.open(writeReviewURL)

    }
    
    func appStoreAction() {
        let urlStr = "itms-apps://itunes.apple.com/app/id\(myBarcode.appStoreId)"
        if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        myBarcodeMatomo.track(action: myBarcodeMatomo.settingsAction, name: myBarcodeMatomo.settingsAppStoreAction)
    }
    
    @IBAction func closeModal(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        performSegue(withIdentifier: "unwindToGenerateViewController", sender: self)
    }
}
