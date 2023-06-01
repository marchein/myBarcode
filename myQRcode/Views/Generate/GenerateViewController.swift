//
//  ViewController.swift
//  myQRcode
//
//  Created by Marc Hein on 24.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import CoreData
import UIKit

class GenerateViewController: UITableViewController, UIDragInteractionDelegate, UITextViewDelegate, HistoryItemDelegate {
    // MARK: - Properties

    @IBOutlet var qrCodeImageView: UIImageView!
    @IBOutlet var qrContentTextView: UITextView!
    @IBOutlet var characterLimitLabel: UILabel!
    @IBOutlet var characterLimitLabelHeight: NSLayoutConstraint!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var generateButton: UIButton!
    @IBOutlet var exportButton: UIButton!
    @IBOutlet var emptyLabel: UILabel!
    @IBOutlet var settingsButton: UIBarButtonItem!
    @IBOutlet var historyButton: UIBarButtonItem!
    
    let hapticsGenerator = UINotificationFeedbackGenerator()
    var qrCodeImage: CIImage!
    var firstAction = true
    var usedTemplate: Template? = nil
    
    var qrPlaceholder = "GENERATE_QR_CODE_PLACEHOLDER".localized
    let maxLength = 2000
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupApp()
        
        qrCodeImageView.addInteraction(UIDragInteraction(delegate: self))
        qrContentTextView.delegate = self
        qrCodeImageView.image = #imageLiteral(resourceName: "Blank QR")
        exportButton.isEnabled = false
        
        setupTextView()
        
        setClearButton()
        setMaxCharacterLabel()
        checkIfGenerationIsPossible()
    }
    
    fileprivate func setupApp() {
        let appSetup = UserDefaults.standard.bool(forKey: localStoreKeys.appSetup)
        
        if !appSetup {
            UserDefaults.standard.set(isSimulatorOrTestFlight(), forKey: localStoreKeys.isTester)
            UserDefaults.standard.set(TabOption.GENERATE.rawValue, forKey: localStoreKeys.defaultTab)
            UserDefaults.standard.set(myQRcode.defaultAppIcon, forKey: localStoreKeys.currentAppIcon)
            UserDefaults.standard.set(true, forKey: localStoreKeys.appSetup)
            UserDefaults.standard.set(0, forKey: localStoreKeys.codeGenerated)
            UserDefaults.standard.set(0, forKey: localStoreKeys.codeScanned)
            UserDefaults.standard.synchronize()
        }
        
        if #available(iOS 13.0,*) {
            settingsButton.image = UIImage(systemName: "gear")
            historyButton.image = UIImage(systemName: "clock")
        }
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let image = qrCodeImageView.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        return [item]
    }
    
    @IBAction func generateButtonPressed(_ sender: Any) {
        generateAction()
    }
    
    func displayQRCodeImage(image: CIImage) {
        qrCodeImageView.image = convertCIImageToUIImage(inputImage: image)
        qrCodeImageView.isUserInteractionEnabled = true
        exportButton.isEnabled = true
        
        checkForFirstAction()
        tabBarController?.hideAnimatedActivityIndicatorView()
    }
    
    // share image
    @IBAction func shareImageButton(_ sender: UIButton) {
        let image = qrCodeImageView.image!
        
        let imageToShare = [image]
        let activityVC = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = sender
        present(activityVC, animated: true, completion: nil)
    }
    
    func userSelectedHistoryItem(item: HistoryItem) {
        resetView()
        enterQR(content: item.content, addToHistory: false)
    }
    
    func enterQR(content: String?, addToHistory: Bool = true) {
        guard let content = content, content.count > 0 else {
            return
        }
        qrContentTextView.text = content
        if #available(iOS 13.0, *) {
            qrContentTextView.textColor = .label
        } else {
            qrContentTextView.textColor = .darkText
        }
        resizeQRTextView()
        checkIfGenerationIsPossible()
        if generateButton.isEnabled {
            generateAction()
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        qrContentTextView.resignFirstResponder()
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
}
