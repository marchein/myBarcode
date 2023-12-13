//
//  Utilities.swift
//  myTodo
//
//  Created by Marc Hein on 15.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

//MARK:- Check for Beta Testers
func isSimulatorOrTestFlight() -> Bool {
    return isSimulator() || isTestFlight()
}

func isSimulator() -> Bool {
    guard let path = Bundle.main.appStoreReceiptURL?.path else {
        return false
    }
    return path.contains("CoreSimulator")
}

func isTestFlight() -> Bool {
    guard let path = Bundle.main.appStoreReceiptURL?.path else {
        return false
    }
    return path.contains("sandboxReceipt")
}

func getReleaseTitle() -> String {
    if isSimulator() {
        return "Simulator"
    } else if isTestFlight() {
        return "TestFlight"
    } else {
        return "App Store"
    }
}

// MARK: - showDialog
func showMessage(title: String, message: String, on view: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "message_okay_action".localized, style: .cancel, handler: nil))
    DispatchQueue.main.async {
        view.present(alert, animated: true)
    }
}

func getCodeValue(from: String) -> Int {
    return UserDefaults.standard.integer(forKey: from)
}

func incrementCodeValue(of: String) {
    let result = getCodeValue(from: of) + 1
    UserDefaults.standard.set(result, forKey: of)
    UserDefaults.standard.synchronize()
    if result == myBarcode.askForReviewAtSingleAction {
        showRateWindow()
    } else if (getCodeValue(from: localStoreKeys.codeGenerated) + getCodeValue(from: localStoreKeys.codeScanned) == myBarcode.askForReviewAtCombinedAction) {
        showRateWindow()
    }
}

func showRateWindow() {
    SKStoreReviewController.requestReviewInCurrentScene()
}

func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
    let context = CIContext(options: nil)
    if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
        return cgImage
    }
    return nil
}

func convertCGImageToUIImage(inputImage: CGImage) -> UIImage {
    return UIImage(cgImage: inputImage)
}

func convertCIImageToUIImage(inputImage: CIImage) -> UIImage? {
    guard let cgImage = convertCIImageToCGImage(inputImage: inputImage) else {
        return nil
    }
    return convertCGImageToUIImage(inputImage: cgImage)
}
