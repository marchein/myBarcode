//
//  GenerateViewController+Helpers.swift
//  myBarcode
//
//  Created by Marc Hein on 19.03.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit
import SwiftUI
import WhatsNewKit

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
        generateButton.alpha = generateButton.isEnabled ? 1.0 : 0.6
    }
    
    // MARK: - View
    func resetView() {
        resignTextViewFirstResponder()
        setClearButton()
        checkIfGenerationIsPossible()
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
            
            let narrowConstraint = codeImageView.heightAnchor.constraint(equalTo: codeImageView.widthAnchor, multiplier: 4.0/1.0)
            let squareConstraint = codeImageView.heightAnchor.constraint(equalTo: codeImageView.widthAnchor, multiplier: 1.0/1.0)
            
            switch selectedCodeType {
            case .CODE128:
                code = Code128(code: code)
                myBarcodeMatomo.track(action: myBarcodeMatomo.generateAction, name: myBarcodeMatomo.generateGeneratedCodeCode128, number: NSNumber(value: getCodeValue(from: localStoreKeys.codeGenerated)))
                narrowConstraint.isActive = true
                squareConstraint.isActive = false
                break
            case .AZTEC:
                code = Aztec(code: code)
                myBarcodeMatomo.track(action: myBarcodeMatomo.generateAction, name: myBarcodeMatomo.generateGeneratedCodeAztec, number: NSNumber(value: getCodeValue(from: localStoreKeys.codeGenerated)))
                narrowConstraint.isActive = false
                squareConstraint.isActive = true
                break
            case .PDF417:
                code = PDF417(code: code)
                myBarcodeMatomo.track(action: myBarcodeMatomo.generateAction, name: myBarcodeMatomo.generateGeneratedCodePDF417, number: NSNumber(value: getCodeValue(from: localStoreKeys.codeGenerated)))
                narrowConstraint.isActive = true
                squareConstraint.isActive = false
                break
            case .QR:
                fallthrough
            default:
                code = QRCode(code: code)
                myBarcodeMatomo.track(action: myBarcodeMatomo.generateAction, name: myBarcodeMatomo.generateGeneratedCodeQR, number: NSNumber(value: getCodeValue(from: localStoreKeys.codeGenerated)))
                narrowConstraint.isActive = false
                squareConstraint.isActive = true
            }
            
            if let usedTemplate = usedTemplate {
                code.setTemplateName(name: usedTemplate.name)
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
                                       
                    let historyDisabled = UserDefaults.standard.bool(forKey: localStoreKeys.historyDisabled)
                    if addToHistory && !historyDisabled {
                        code.addToCoreData()
                    }
                    self.currentCode = code
                    self.generateButton.isEnabled = false
                    self.generateButton.alpha = self.generateButton.isEnabled ? 1.0 : 0.6
                    
                    myBarcodeMatomo.track(action: myBarcodeMatomo.generateAction, name: myBarcodeMatomo.generateGeneratedCode, number: NSNumber(value: getCodeValue(from: localStoreKeys.codeGenerated)))
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
    
    func showChangelog() {
        // Verify WhatsNewViewController is available for presentation
        guard let whatsNewViewController = WhatsNewViewController(
            whatsNew: WhatsNew(
                version: "2.0",
                title: .init(stringLiteral: "CHANGELOG_HEADLINE".localized),
                features: [
                    .init(
                        image: .init(
                            systemName: "star.fill",
                            foregroundColor: .yellow
                        ),
                        title: .init("CHANGELOG_2_0_TOP1_TITLE".localized),
                        subtitle: .init("CHANGELOG_2_0_TOP1_SUBTITLE".localized)
                    ),
                    .init(
                        image: .init(
                            systemName: "barcode",
                            foregroundColor: Color(uiColor: .label)
                        ),
                        title: .init("CHANGELOG_2_0_TOP2_TITLE".localized),
                        subtitle: .init("CHANGELOG_2_0_TOP2_SUBTITLE".localized)
                    ),
                    .init(
                        image: .init(
                            systemName: "barcode.viewfinder",
                            foregroundColor: .green
                        ),
                        title: .init("CHANGELOG_2_0_TOP3_TITLE".localized),
                        subtitle: .init("CHANGELOG_2_0_TOP3_SUBTITLE".localized)
                    ),
                    .init(
                        image: .init(
                            systemName: "gear.circle.fill",
                            foregroundColor: .gray
                        ),
                        title: .init("CHANGELOG_2_0_TOP4_TITLE".localized),
                        subtitle: .init("CHANGELOG_2_0_TOP4_SUBTITLE".localized)
                    )
                ],
                primaryAction: .init(
                    title: .init("CHANGELOG_CONTINUE".localized)
                )
            ),
            versionStore: UserDefaultsWhatsNewVersionStore()
        ) else {
            // Version of WhatsNew has already been presented
            return
        }

        // Present WhatsNewViewController
        // Version will be automatically saved in the provided
        // WhatsNewVersionStore when the WhatsNewViewController gets dismissed
        #if !targetEnvironment(simulator)
        self.present(whatsNewViewController, animated: true)
        #endif
    }
}
