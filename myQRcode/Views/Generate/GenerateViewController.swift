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
    @IBOutlet var qrCodeImageView: UIImageView!
    @IBOutlet var qrContentTextView: UITextView!
    //@IBOutlet var qrContentTextField: UITextField!
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
    
    var defaultString = NSLocalizedString("GENERATE_QR_CODE_PLACEHOLDER", comment: "Placeholder for textview")
    let maxLength = 1500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupApp()
        
        qrCodeImageView.addInteraction(UIDragInteraction(delegate: self))
        qrContentTextView.delegate = self
        qrCodeImageView.image = #imageLiteral(resourceName: "Blank QR")
        exportButton.isEnabled = false
        
        setupTextView()
        //qrContentTextView.addTarget(self, action: #selector(checkIfGenerationIsPossible), for: UIControl.Event.editingChanged)
        
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
    
    func setupTextView() {
        if #available(iOS 13.0,*) {
            qrContentTextView.textColor = .placeholderText
        }
        qrContentTextView.isScrollEnabled = false
        qrContentTextView.text = defaultString
    }
    
    func textViewDidBeginEditing (_ textView: UITextView) {
        if #available(iOS 13.0,*) {
            if qrContentTextView.textColor == .placeholderText && qrContentTextView.isFirstResponder {
                qrContentTextView.text = nil
                qrContentTextView.textColor = .label
            }
        }
    }
    
    func textViewDidEndEditing (_ textView: UITextView) {
        resetTextView()
        qrContentTextView.resignFirstResponder()
    }
    
    func resetTextView() {
        if qrContentTextView.text.isEmpty || qrContentTextView.text == "" {
            if #available(iOS 13.0,*) {
                qrContentTextView.textColor = .placeholderText
            } else {
                qrContentTextView.textColor = .lightGray
            }
            qrContentTextView.text = defaultString
            resignTextViewFirstResponder()
        }
    }
    
    // MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        let startHeight = textView.frame.size.height
        let calcHeight = textView.sizeThatFits(textView.frame.size).height  //iOS 8+ only
        
        if startHeight != calcHeight {
            
            UIView.setAnimationsEnabled(false) // Disable animations
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            
            // Might need to insert additional stuff here if scrolls
            // table in an unexpected way.  This scrolls to the bottom
            // of the table. (Though you might need something more
            // complicated if editing in the middle.)
            
            let scrollTo = self.tableView.contentSize.height - self.tableView.frame.size.height
            self.tableView.setContentOffset(CGPoint(x: 0, y: scrollTo), animated: false)
            
            UIView.setAnimationsEnabled(true)  // Re-enable animations.
            
        }
        setMaxCharacterLabel()
        checkIfGenerationIsPossible()
        resetTextView()
    }
    
    func setMaxCharacterLabel() {
        guard let qrContent = qrContentTextView.text else { return }
        
        let currentCount = qrContent == defaultString ? 0 : qrContent.count
        characterLimitLabel.text = "\(maxLength - currentCount) \(NSLocalizedString("GENERATE_CHARS_LEFT", comment: "000 x left"))"
        characterLimitLabelHeight.constant = Double(currentCount) > Double(maxLength) * 0.8 ? 14 : 0
        setClearButton()
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 ||  section == 1 || (section == 2 && usedTemplate != nil) {
            return 2
        }
        return 1
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            if generateButton.isEnabled {
                view.endEditing(true)
                generateAction()
            }
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if generateButton.isEnabled {
            view.endEditing(true)
            generateAction()
        }
        return false
    }
    
    @objc func checkIfGenerationIsPossible() {
        let currentCount = qrContentTextView.text?.count ?? 0
        generateButton.isEnabled = currentCount > 0 && currentCount < maxLength && qrContentTextView.text! != defaultString
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let image = qrCodeImageView.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        return [item]
    }
    
    fileprivate func resetView() {
        resignTextViewFirstResponder()
        setClearButton()
        generateButton.isEnabled = false
        qrCodeImageView.isUserInteractionEnabled = false
        qrCodeImageView.image = #imageLiteral(resourceName: "Blank QR")
        qrContentTextView.text = nil
        qrCodeImage = nil
        exportButton.isEnabled = false
    }
    
    @IBAction func generateButtonPressed(_ sender: Any) {
        generateAction()
    }
    
    func generateAction(addToHistory: Bool = true) {
        guard
            let qrData = qrContentTextView.text
        else {
            return
        }
        
        qrContentTextView.resignFirstResponder()
                
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
                        qrCode.addToCoreData()
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
    
    func userSelectedHistoryItem(item: HistoryItem) {
        resetView()
        enterQR(content: item.content, addToHistory: false)
    }
    
    func enterQR(content: String?, addToHistory: Bool = true) {
        guard let content = content, content.count > 0 else {
            return
        }
        qrContentTextView.text = content
        checkIfGenerationIsPossible()
        if generateButton.isEnabled {
            generateAction()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resignTextViewFirstResponder()
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func resignTextViewFirstResponder() {
        qrContentTextView.resignFirstResponder()
    }
    
    func setClearButton() {
        guard let qrContent = qrContentTextView.text else { return }

        clearButton.isHidden = qrContent == defaultString || qrContent.isEmpty
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        qrContentTextView.text = defaultString
        if #available(iOS 13.0,*) {
            qrContentTextView.textColor = .placeholderText
        } else {
            qrContentTextView.textColor = .lightGray
        }
        setMaxCharacterLabel()
        checkIfGenerationIsPossible()
        resignTextViewFirstResponder()
    }
}

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}
