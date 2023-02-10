//
//  ViewController.swift
//  myQRcode
//
//  Created by Marc Hein on 24.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import CoreData
import UIKit

class GenerateViewController: UITableViewController, UIDragInteractionDelegate, UITextFieldDelegate, HistoryItemDelegate {
    @IBOutlet var qrCodeImageView: UIImageView!
    @IBOutlet var qrContentTextField: UITextField!
    @IBOutlet var generateButton: UIButton!
    @IBOutlet var exportButton: UIButton!
    @IBOutlet var emptyLabel: UILabel!
    @IBOutlet var settingsButton: UIBarButtonItem!
    @IBOutlet var historyButton: UIBarButtonItem!
    
    let hapticsGenerator = UINotificationFeedbackGenerator()
    var qrCodeImage: CIImage!
    var firstAction = true
    var usedTemplate: Template? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupApp()
        
        qrCodeImageView.addInteraction(UIDragInteraction(delegate: self))
        qrContentTextField.delegate = self
        qrCodeImageView.image = #imageLiteral(resourceName: "Blank QR")
        exportButton.isEnabled = false
        
        qrContentTextField.addTarget(self, action: #selector(checkIfGenerationIsPossible), for: UIControl.Event.editingChanged)
        
        checkIfGenerationIsPossible()
        if #available(iOS 13.0, *), let tabBarController = navigationController?.parent as? UITabBarController, let items = tabBarController.tabBar.items {
            var index = 0
            for item in items {
                if index == 0 {
                    item.image = UIImage(systemName: "qrcode")
                } else if index == 1 {
                    item.image = UIImage(systemName: "qrcode.viewfinder")
                }
                index += 1
            }
        }
    }
    
    fileprivate func setupApp() {
        let appSetup = UserDefaults.standard.bool(forKey: localStoreKeys.appSetup)
        
        if !appSetup {
            UserDefaults.standard.set(isSimulatorOrTestFlight(), forKey: localStoreKeys.isTester)
            UserDefaults.standard.set(myQRcode.defaultAppIcon, forKey: localStoreKeys.currentAppIcon)
            UserDefaults.standard.set(true, forKey: localStoreKeys.appSetup)
            UserDefaults.standard.set(0, forKey: localStoreKeys.codeGenerated)
            UserDefaults.standard.set(0, forKey: localStoreKeys.codeScanned)
        }
        
        if #available(iOS 13.0,*) {
            settingsButton.image = UIImage(systemName: "gear")
            historyButton.image = UIImage(systemName: "clock")
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 || (section == 2 && usedTemplate != nil) {
            return 2
        }
        return 1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        generateAction()
        return false
    }
    
    @objc func checkIfGenerationIsPossible() {
        let currentCount = qrContentTextField.text?.count ?? 0
        generateButton.isEnabled = currentCount > 0 && currentCount < 1500
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let image = qrCodeImageView.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        return [item]
    }
    
    fileprivate func resetView() {
        generateButton.isEnabled = false
        qrCodeImageView.isUserInteractionEnabled = false
        qrCodeImageView.image = #imageLiteral(resourceName: "Blank QR")
        qrContentTextField.text = nil
        qrCodeImage = nil
        exportButton.isEnabled = false
    }
    
    @IBAction func generateButtonPressed(_ sender: Any) {
        generateAction()
    }
    
    func generateAction(addToHistory: Bool = true) {
        guard
            let qrData = qrContentTextField.text
        else {
            return
        }
        
        qrContentTextField.resignFirstResponder()
                
        if qrCodeImage == nil {
            tabBarController?.displayAnimatedActivityIndicatorView()
            
            DispatchQueue.global(qos: .background).async {
                let qrCode = QRCode(content: qrData, category: .generate)
                DispatchQueue.main.async {
                    self.hapticsGenerator.prepare()
                    self.hapticsGenerator.notificationOccurred(.success)
                    let resultImage = qrCode.generateImage()
                    self.displayQRCodeImage(image: resultImage)
                    incrementCodeValue(of: localStoreKeys.codeGenerated)
                    if addToHistory {
                        _ = qrCode.addToCoreData()
                    }
                    self.generateButton.isEnabled = false
                }
            }
        }
    }
    
    func displayQRCodeImage(image: CIImage) {
        qrCodeImageView.image = convertCIImageToUIImage(inputImage: image)
        qrCodeImageView.isUserInteractionEnabled = true
        exportButton.isEnabled = true
        
        checkForFirstAction()
        tabBarController?.hideAnimatedActivityIndicatorView()
    }
    
    func checkForFirstAction() {
        if firstAction {
            firstAction = false
            emptyLabel.removeFromSuperview()
        }
    }
    
    // share image
    @IBAction func shareImageButton(_ sender: UIButton) {
        let image = qrCodeImageView.image!
        
        let imageToShare = [image]
        let activityVC = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = sender
        present(activityVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == myQRcodeSegues.ShowHistorySegue {
            guard
                let historyNavVC = segue.destination as? UINavigationController,
                let historyVC = historyNavVC.children[0] as? HistoryTableViewController
            else {
                return
            }
            historyVC.delegate = self
            historyVC.category = .generate
        } else if segue.identifier == myQRcodeSegues.GenerateToTemplateSegue {
            guard
                let templateNavVC = segue.destination as? UINavigationController,
                let templateList = templateNavVC.children[0] as? TemplateListTableViewController
            else {
                return
            }
            templateList.generateVC = self
        } else if segue.identifier == myQRcodeSegues.ReuseTemplateSegue {
            guard
                let templateNavVC = segue.destination as? UINavigationController,
                let templateList = templateNavVC.children[0] as? TemplateListTableViewController
            else {
                return
            }
            templateList.generateVC = self
            templateList.performSegue(withIdentifier: myQRcodeSegues.EditTemplateSegue, sender: usedTemplate)
        }
    }
    
    func userSelectedHistoryItem(item: HistoryItem) {
        resetView()
        enterQR(content: item.content, addToHistory: false)
    }
    
    func enterQR(content: String?, addToHistory: Bool = true) {
        guard let content = content, content.count > 0 else {
            return
        }
        qrContentTextField.text = content
        checkIfGenerationIsPossible()
        if generateButton.isEnabled {
            generateAction()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}
