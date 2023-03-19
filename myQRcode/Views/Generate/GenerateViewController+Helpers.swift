//
//  GenerateViewController+Helpers.swift
//  myQRcode
//
//  Created by Marc Hein on 19.03.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

extension GenerateViewController {
    // MARK: - Input
    func setMaxCharacterLabel() {
        guard let qrContent = qrContentTextView.text else { return }
        
        let currentCount = qrContent == qrPlaceholder ? 0 : qrContent.count
        if currentCount <= maxLength {
            characterLimitLabel.text = "\(maxLength - currentCount) \("GENERATE_CHARS_LEFT".localized)"
            if #available(iOS 13.0, *) {
                characterLimitLabel.textColor = .secondaryLabel
            } else {
                characterLimitLabel.textColor = .lightGray
            }
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
        let currentCount = qrContentTextView.text?.count ?? 0
        let hasContent = currentCount > 0
        let contentInLimit = currentCount < maxLength
        let hasPlaceholderText = qrContentTextView.text! == qrPlaceholder
        
        generateButton.isEnabled = hasContent && contentInLimit && !hasPlaceholderText
    }
    
    // MARK: - View
    func resetView() {
        resignTextViewFirstResponder()
        setClearButton()
        generateButton.isEnabled = false
        qrCodeImageView.isUserInteractionEnabled = false
        qrCodeImageView.image = #imageLiteral(resourceName: "Blank QR")
        qrContentTextView.text = nil
        qrCodeImage = nil
        exportButton.isEnabled = false
    }
    
    // MARK: - Actions
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
    
    func checkForFirstAction() {
        if firstAction {
            firstAction = false
            emptyLabel.removeFromSuperview()
        }
    }
}
