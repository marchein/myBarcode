//
//  ScanViewController+ImagePicker.swift
//  myBarcode
//
//  Created by Marc Hein on 21.08.20.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

extension ScanViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func pickImageUsingUIImagePicker() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard
            let codeImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        else {
            return
        }
        
        self.dismiss(animated: true) {
            let codeContents = self.processSelectedImage(codeImg)
            self.processingImageComplete(codeContents)
            
            myBarcodeMatomo.track(action: myBarcodeMatomo.scanAction, name: myBarcodeMatomo.scanImageScanned)
        }
    }
}
