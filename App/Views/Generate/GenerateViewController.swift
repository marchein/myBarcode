//
//  ViewController.swift
//  myBarcode
//
//  Created by Marc Hein on 24.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import CoreData
import UIKit

class GenerateViewController: UITableViewController, UIDragInteractionDelegate, UITextViewDelegate, HistoryItemDelegate {
    // MARK: - Properties
    
    @IBOutlet weak var codeTypeSelector: UISegmentedControl!
    @IBOutlet var codeImageView: UIImageView!
    @IBOutlet var codeContentTextView: UITextView!
    @IBOutlet var characterLimitLabel: UILabel!
    @IBOutlet var characterLimitLabelHeight: NSLayoutConstraint!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var generateButton: UIButton!
    @IBOutlet var exportButton: UIButton!
    @IBOutlet var emptyLabel: UILabel!
    @IBOutlet var settingsButton: UIBarButtonItem!
    @IBOutlet var historyButton: UIBarButtonItem!
    
    var hideCodeTypeSelector = false
    var historyDisabled = false
    var selectedCodeType: PossibleCodes!
    let hapticsGenerator = UINotificationFeedbackGenerator()
    var codeImage: CIImage!
    var firstAction = true
    var usedTemplate: Template?
    var currentCode: Code?
    
    var codePlaceholder = "GENERATE_CODE_PLACEHOLDER".localized
    var maxLength = -1
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupApp()
        
        codeImageView.addInteraction(UIDragInteraction(delegate: self))
        codeContentTextView.delegate = self
        updateImageViewForFirstAction()
        exportButton.isEnabled = false
        hideCodeTypeSelector = UserDefaults.standard.bool(forKey: localStoreKeys.showOnlyDefaultCode)
        
        setupTextView()
        setupSegmentedControl()
        setDefaultCodeType()
        setHistory()
        
        setClearButton()
        setMaxCharacterLabel()
        checkIfGenerationIsPossible()
        
        tableView.reloadData()
        
        showChangelog()
        
        myBarcodeMatomo.track(action: myBarcodeMatomo.basicAction, name: myBarcodeMatomo.generateViewShown)
    }
    
    
    fileprivate func setupApp() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not find AppDelegate")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            appDelegate.appTracking.requestTracking()
        }
        
        
        
        let appSetup = UserDefaults.standard.bool(forKey: localStoreKeys.appSetup)
        
        if !appSetup {
            UserDefaults.standard.set(isSimulatorOrTestFlight(), forKey: localStoreKeys.isTester)
            UserDefaults.standard.set(TabOption.GENERATE.rawValue, forKey: localStoreKeys.defaultTab)
            UserDefaults.standard.set(false, forKey: localStoreKeys.showOnlyDefaultCode)
            UserDefaults.standard.set(PossibleCodes.QR.rawValue, forKey: localStoreKeys.defaultCode)
            UserDefaults.standard.set(false, forKey: localStoreKeys.historyDisabled)
            UserDefaults.standard.set(0, forKey: localStoreKeys.codeGenerated)
            UserDefaults.standard.set(0, forKey: localStoreKeys.codeScanned)
            UserDefaults.standard.set(true, forKey: localStoreKeys.appSetup)
            
            UserDefaults.standard.synchronize()
        }
        
        
    }
    
    func setupSegmentedControl() {
        codeTypeSelector.removeAllSegments()
        Model.possibleCodes.indices.forEach { index in
            codeTypeSelector.insertSegment(withTitle: Model.possibleCodes[index].displayNameShort, at: index, animated: false)
        }
    }
    
    func setDefaultCodeType() {
        selectedCodeType = PossibleCodes(rawValue: UserDefaults.standard.integer(forKey: localStoreKeys.defaultCode)) ?? .QR
        codeTypeSelector.selectedSegmentIndex = selectedCodeType.rawValue
        codeTypeSelectorChanged(codeTypeSelector)
        checkIfGenerationIsPossible()
    }
    
    
    @IBAction func codeTypeSelectorChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        
        if selectedCodeType.rawValue != selectedIndex {
            checkIfGenerationIsPossible()
        }
        
        selectedCodeType = PossibleCodes(rawValue: selectedIndex) ?? PossibleCodes.QR
        
        codeImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        codeImageView.heightAnchor.constraint(equalTo: codeImageView.widthAnchor, multiplier: 1/1).isActive = true
        
        switch selectedCodeType {
        case .CODE128:
            maxLength = Code128.maxLength
        case .PDF417:
            maxLength = PDF417.maxLength
        case .AZTEC:
            maxLength = Aztec.maxLength
        case .QR:
            fallthrough
        default:
            maxLength = QRCode.maxLength
        }
        
        updateImageViewForFirstAction()
        setMaxCharacterLabel()
        checkIfGenerationIsPossible()
        
        tableView.reloadData()
    }
    
    func setHistory() {
        if #available(iOS 16.0, *) {
            historyButton.isHidden = historyDisabled
        } else {
            historyButton.isEnabled = !historyDisabled
        }
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let image = codeImageView.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        
        myBarcodeMatomo.track(action: myBarcodeMatomo.generateAction, name: myBarcodeMatomo.generateExport)
        return [item]
    }
    
    @IBAction func generateButtonPressed(_ sender: Any) {
        generateAction()
    }
    
    func displayCodeImage(image: CIImage) {
        codeImageView.image = convertCIImageToUIImage(inputImage: image)
        codeImageView.isUserInteractionEnabled = true
        exportButton.isEnabled = true
        
        checkForFirstAction()
        tabBarController?.hideAnimatedActivityIndicatorView()
    }
    
    func updateImageViewForFirstAction() {
        if !firstAction {
            return
        }
        
        codeImageView.image = selectedCodeType != .CODE128 && selectedCodeType != .PDF417 ? #imageLiteral(resourceName: "Blank QR") : nil
    }
    
    // share image
    @IBAction func shareImageButton(_ sender: UIButton) {
        let image = codeImageView.image!
        
        let imageToShare = [image]
        let activityVC = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = sender
        present(activityVC, animated: true, completion: nil)
        
        myBarcodeMatomo.track(action: myBarcodeMatomo.generateAction, name: myBarcodeMatomo.generateExport)
    }
    
    func userSelectedHistoryItem(item: HistoryItem) {
        resetView()
        let type = myBarcode.codeStrings[item.type ?? "QR"] ?? .QR
        codeTypeSelector.selectedSegmentIndex = type.rawValue
        
        enterCode(content: item.content, codeType: type, addToHistory: false, resetToDefaultCodeType: false)
    }
    
    func enterCode(content: String?, codeType: PossibleCodes? = nil, addToHistory: Bool = true, resetToDefaultCodeType: Bool = true) {
        guard let content = content, content.count > 0 else {
            return
        }
        
        codeTypeSelector.selectedSegmentIndex = (codeType ?? selectedCodeType).rawValue
        
        codeTypeSelectorChanged(codeTypeSelector!)
        
        codeContentTextView.text = content
        codeContentTextView.textColor = .label
        
        resizeCodeContentTextView()
        checkIfGenerationIsPossible()
        if generateButton.isEnabled {
            generateAction(addToHistory: codeType == nil)
        }
        
        if resetToDefaultCodeType {
            setDefaultCodeType()
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        codeContentTextView.resignFirstResponder()
        if segue.identifier == myBarcodeSegues.ShowHistorySegue {
            guard
                let historyNavVC = segue.destination as? UINavigationController,
                let historyVC = historyNavVC.children[0] as? HistoryTableViewController
            else {
                return
            }
            historyVC.delegate = self
            historyVC.category = .generate
        } else if segue.identifier == myBarcodeSegues.GenerateToTemplateSegue {
            guard
                let templateNavVC = segue.destination as? UINavigationController,
                let templateList = templateNavVC.children[0] as? TemplateListTableViewController
            else {
                return
            }
            templateList.generateVC = self
        } else if segue.identifier == myBarcodeSegues.ReuseTemplateSegue {
            guard
                let templateNavVC = segue.destination as? UINavigationController,
                let templateList = templateNavVC.children[0] as? TemplateListTableViewController
            else {
                return
            }
            templateList.generateVC = self
            templateList.performSegue(withIdentifier: myBarcodeSegues.EditTemplateSegue, sender: usedTemplate)
            myBarcodeMatomo.track(action: myBarcodeMatomo.generateAction, name: myBarcodeMatomo.generateReusedTemplate)
        }
    }
    
    func updateViewFromSettings() {
        // Wether the selection should still be shown or not
        hideCodeTypeSelector = UserDefaults.standard.bool(forKey: localStoreKeys.showOnlyDefaultCode)
        
        // Which code should be selected
        setDefaultCodeType()
        
        historyDisabled = UserDefaults.standard.bool(forKey: localStoreKeys.historyDisabled)
        
        // Show/Hide History
        setHistory()
    }
    
    @IBAction func unwindToGenerateViewController(segue: UIStoryboardSegue) {
        updateViewFromSettings()
    }
}
