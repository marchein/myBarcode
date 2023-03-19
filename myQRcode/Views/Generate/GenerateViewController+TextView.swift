//
//  GenerateViewController+TextView.swift
//  myQRcode
//
//  Created by Marc Hein on 19.03.23.
//  Copyright © 2023 Marc Hein Webdesign. All rights reserved.
//

import UIKit

extension GenerateViewController {
    func setupTextView() {
        if #available(iOS 13.0,*) {
            qrContentTextView.textColor = .placeholderText
        }
        qrContentTextView.isScrollEnabled = false
        qrContentTextView.text = qrPlaceholder
    }
    
    func resetTextView() {
        if qrContentTextView.text.isEmpty || qrContentTextView.text == "" {
            if #available(iOS 13.0,*) {
                qrContentTextView.textColor = .placeholderText
            } else {
                qrContentTextView.textColor = .lightGray
            }
            qrContentTextView.text = qrPlaceholder
            resignTextViewFirstResponder()
        }
    }
    
    func resizeQRTextView() {
        let startHeight = qrContentTextView.frame.size.height
        let calcHeight = qrContentTextView.sizeThatFits(qrContentTextView.frame.size).height  //iOS 8+ only
        
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
        if #available(iOS 13.0,*) {
            if qrContentTextView.textColor == .placeholderText && qrContentTextView.isFirstResponder {
                qrContentTextView.text = nil
                qrContentTextView.textColor = .label
            }
        } else {
            if qrContentTextView.textColor == .lightGray && qrContentTextView.isFirstResponder {
                qrContentTextView.text = nil
                qrContentTextView.textColor = .darkText
            }
        }
    }
    
    func textViewDidEndEditing (_ textView: UITextView) {
        resetTextView()
        qrContentTextView.resignFirstResponder()
    }    
    
    func textViewDidChange(_ textView: UITextView) {
        resizeQRTextView()
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
        qrContentTextView.resignFirstResponder()
    }
    
    func setClearButton() {
        guard let qrContent = qrContentTextView.text else { return }

        clearButton.isHidden = qrContent == qrPlaceholder || qrContent.isEmpty
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        qrContentTextView.text = qrPlaceholder
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
