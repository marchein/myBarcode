//
//  ViewController.swift
//  myQRcode
//
//  Created by Marc Hein on 24.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit
import CoreData

class GenerateViewController: UITableViewController, UIDragInteractionDelegate, UITextFieldDelegate, HistoryItemDelegate {
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var qrContentTextField: UITextField!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var historyButton: UIBarButtonItem!
    
    var qrCodeImage: CIImage!
    var firstAction = true
    
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
            var index = 0;
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
        
        if #available(iOS 13.0,*)  {
            settingsButton.image = UIImage(systemName: "gear")
            historyButton.image = UIImage(systemName: "clock")
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        generateButtonAction(textField)
        return false
    }
    
    @objc func checkIfGenerationIsPossible() {
        let currentCount = qrContentTextField.text?.count ?? 0
        generateButton.isEnabled = currentCount > 0 && currentCount < 1000
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
    
    @IBAction func generateButtonAction(_ sender: Any) {
        guard let qrData = qrContentTextField.text else { return }
        qrContentTextField.resignFirstResponder()
        
        if qrCodeImage == nil {
            if qrData == "" {
                return
            }
            self.tabBarController?.displayAnimatedActivityIndicatorView()
            
            DispatchQueue.global(qos: .background).async {
                let qrCode = QRCode(content: qrData, category: .generate)
                DispatchQueue.main.async {
                    if let resultImage = qrCode.image {
                        self.displayQRCodeImage(image: resultImage)
                        incrementCodeValue(of: localStoreKeys.codeGenerated)
                        _ = qrCode.coreDataObject
                        self.generateButton.isEnabled = false
                    } else {
                        self.tabBarController?.hideAnimatedActivityIndicatorView()
                        return
                    }
                }
            }
        }
    }
    
    
    
    func displayQRCodeImage(image: UIImage) {
        qrCodeImageView.image = image
        qrCodeImageView.isUserInteractionEnabled = true
        exportButton.isEnabled = true
        
        self.checkForFirstAction()
        self.tabBarController?.hideAnimatedActivityIndicatorView()
        //hud.dismiss()
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
        self.present(activityVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHistory" {
            guard let historyNavVC = segue.destination as? UINavigationController, let historyVC = historyNavVC.children[0] as? HistoryTableViewController else {
                return
            }
            historyVC.delegate = self
            historyVC.category = .generate
        }
    }
    
    func userSelectedHistoryItem(item: HistoryItem) {
        self.resetView()
        self.qrContentTextField.text = item.content
        self.displayQRCodeImage(image: convertBase64ToImage(imageString: item.imageString!))
    }
    
    func convertBase64ToImage(imageString: String) -> UIImage {
        let imageData = Data(base64Encoded: imageString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
        return UIImage(data: imageData)!
    }
}

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}
