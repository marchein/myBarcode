//
//  ScanViewController+PHPicker.swift
//  myBarcode
//
//  Created by Marc Hein on 10.02.23.
//  Copyright © 2023 Marc Hein Webdesign. All rights reserved.
//

import PhotosUI
import HeinHelpers

extension ScanViewController: PHPickerViewControllerDelegate {
    func pickPhotoUsingPHPicker() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard results.first != nil else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        picker.dismiss(animated: true) {
            let itemProvider = results.first!.itemProvider
            
            itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                
                DispatchQueue.main.async {
                    guard let codeImg = image as? UIImage, let codeContents = self.processSelectedImage(codeImg) else {
                        self.noQrCodeDetected()
                        return
                    }
                    self.processingImageComplete(codeContents)
                }
            }
        }
    }
}
