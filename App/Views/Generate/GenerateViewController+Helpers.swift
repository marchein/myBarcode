//
//  GenerateViewController+Helpers.swift
//  myBarcode
//
//  Created by Marc Hein on 19.03.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

extension GenerateViewController {
    // MARK: - Input
    func setMaxCharacterLabel() {
        guard let codeContent = codeContentTextView.text else { return }
        
        let currentCount = codeContent == codePlaceholder ? 0 : codeContent.count
        if currentCount <= maxLength {
            characterLimitLabel.text = "\(maxLength - currentCount) \("GENERATE_CHARS_LEFT".localized)"
            characterLimitLabel.textColor = .secondaryLabel
        } else {
            characterLimitLabel.text = "\((maxLength - currentCount) * -1) \("GENERATE_CHARS_TOO_MUCH".localized)"
            characterLimitLabel.textColor = .systemRed
        }
        characterLimitLabelHeight.constant = Double(currentCount) > Double(maxLength) * 0.8 ? 14 : 0
        setClearButton()
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @objc func checkIfGenerationIsPossible() {
        let currentCount = codeContentTextView.text?.count ?? 0
        let hasContent = currentCount > 0
        let contentInLimit = currentCount <= maxLength
        let hasNoPlaceholderText = codeContentTextView.text! != codePlaceholder
        
        generateButton.isEnabled = hasContent && contentInLimit && hasNoPlaceholderText
    }
    
    // MARK: - View
    func resetView() {
        resignTextViewFirstResponder()
        setClearButton()
        generateButton.isEnabled = false
        codeImageView.isUserInteractionEnabled = false
        codeImageView.image = #imageLiteral(resourceName: "Blank QR")
        codeContentTextView.text = nil
        codeImage = nil
        exportButton.isEnabled = false
    }
    
    // MARK: - Actions
    func generateAction(addToHistory: Bool = true) {
        guard
            let codeData = codeContentTextView.text
        else {
            return
        }
        
        codeContentTextView.resignFirstResponder()
                
        if codeImage == nil {
            tabBarController?.displayAnimatedActivityIndicatorView()
            
            var code = Code(content: codeData, category: .generate)
            
            switch selectedCodeType {
            case .CODE128:
                code = Code128(code: code)
                break
            case .AZTEC:
                code = Aztec(code: code)
                break
            case .PDF417:
                code = PDF417(code: code)
                break
            case .QR:
                fallthrough
            default:
                code = QRCode(code: code)
            }
            
            let actualCodeType = selectedCodeType ?? .QR
            codeTypeSelector.selectedSegmentIndex = actualCodeType.rawValue
            codeTypeSelectorChanged(codeTypeSelector!)
             
            
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    self.hapticsGenerator.prepare()
                    self.hapticsGenerator.notificationOccurred(.success)
                    let resultImage = code.generateImage()
                    self.displayCodeImage(image: resultImage)
                    incrementCodeValue(of: localStoreKeys.codeGenerated)
                    if addToHistory {
                        code.addToCoreData()
                    }
                    self.generateButton.isEnabled = false
                    
                    myBarcodeMatomo.track(action: myBarcodeMatomo.generateAction, name: myBarcodeMatomo.generateGeneratedQR, number: NSNumber(value: getCodeValue(from: localStoreKeys.codeGenerated)))
                }
            }
        }
    }
    
    func checkForFirstAction() {
        if !firstAction {
            return
        }
        
        firstAction = false
        emptyLabel.removeFromSuperview()
    }
}
