//
//  ScanViewController+ImagePicker.swift
//  myQRcode
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
            let qrCodeImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        else {
            return
        }
        
        self.dismiss(animated: true) {
            let qrCodeContents = self.processSelectedImage(qrCodeImg)
            self.processingImageComplete(qrCodeContents)
        }
    }
}
