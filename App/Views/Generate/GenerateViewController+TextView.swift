//
//  GenerateViewController+TextView.swift
//  myBarcode
//
//  Created by Marc Hein on 19.03.23.
//  Copyright © 2023 Marc Hein Webdesign. All rights reserved.
//

import UIKit

extension GenerateViewController {
    func setupTextView() {
        codeContentTextView.textColor = .placeholderText
        codeContentTextView.isScrollEnabled = false
        codeContentTextView.text = codePlaceholder
    }
    
    func resetTextView() {
        if codeContentTextView.text.isEmpty || codeContentTextView.text == "" {
            codeContentTextView.textColor = .placeholderText
            codeContentTextView.text = codePlaceholder
            resignTextViewFirstResponder()
        }
    }
    
    func resizeCodeContentTextView() {
        let startHeight = codeContentTextView.frame.size.height
        let calcHeight = codeContentTextView.sizeThatFits(codeContentTextView.frame.size).height  //iOS 8+ only
        
        if startHeight != calcHeight {
            UIView.setAnimationsEnabled(false)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            
            // Set the height to a fixed value to fix janky scrolling
            if calcHeight > 250 {
                let scrollTo = self.tableView.contentSize.height - self.tableView.frame.size.height
                self.tableView.setContentOffset(CGPoint(x: 0, y: scrollTo), animated: false)
            }
            UIView.setAnimationsEnabled(true)
        }
    }
    
    // MARK: UITextViewDelegate
    func textViewDidBeginEditing (_ textView: UITextView) {
        if codeContentTextView.textColor == .placeholderText && codeContentTextView.isFirstResponder {
            codeContentTextView.text = nil
            codeContentTextView.textColor = .label
        }
    }
    
    func textViewDidEndEditing (_ textView: UITextView) {
        resetTextView()
        codeContentTextView.resignFirstResponder()
    }    
    
    func textViewDidChange(_ textView: UITextView) {
        resizeCodeContentTextView()
        setMaxCharacterLabel()
        checkIfGenerationIsPossible()
        resetTextView()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
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
    
    func resignTextViewFirstResponder() {
        codeContentTextView.resignFirstResponder()
    }
    
    func setClearButton() {
        guard let codeContent = codeContentTextView.text else { return }

        clearButton.isHidden = codeContent == codePlaceholder || codeContent.isEmpty
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        codeContentTextView.text = codePlaceholder
        codeContentTextView.textColor = .placeholderText
        setMaxCharacterLabel()
        checkIfGenerationIsPossible()
        resignTextViewFirstResponder()
    }
}
