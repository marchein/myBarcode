//
//  ScanViewController+ImagePicker.swift
//  myQRcode
//
//  Created by Marc Hein on 21.08.20.
//  Copyright © 2020 Marc Hein Webdesign. All rights reserved.
//

import UIKit

extension ScanViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBAction func gallerySelectionButtonTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let qrCodeImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
            let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh]),
            let ciImage:CIImage=CIImage(image: qrCodeImg),
            let features = detector.features(in: ciImage) as? [CIQRCodeFeature]else {
                fatalError("Something went wrong in the image picker code")
        }
        
        var qrCodeResult = ""
        for feature in features  {
            if let message = feature.messageString {
                qrCodeResult += message
            }
        }
        
        self.dismiss(animated: true) {
            if qrCodeResult.isEmpty {
                showMessage(title: NSLocalizedString("no_qr_code_error", comment: ""), message: NSLocalizedString("no_qr_code_error_description", comment: ""), on: self.navigationController!)
            } else {
                self.finishedScanning(content: qrCodeResult)
            }
        }
    }
}
