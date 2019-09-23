//
//  ViewController.swift
//  myQRcode
//
//  Created by Marc Hein on 24.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import UIKit

import JGProgressHUD

class GenerateViewController: UITableViewController, UIDragInteractionDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var qrCodeImage: CIImage!
    var firstAction = true
    internal var hud: JGProgressHUD = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.addInteraction(UIDragInteraction(delegate: self))
        
        textField.delegate = self
                
        imageView.image = #imageLiteral(resourceName: "Blank QR")
        exportButton.isEnabled = false

        
        textField.addTarget(self, action: #selector(checkIfGenerationIsPossible), for: UIControl.Event.editingChanged)
                
        checkIfGenerationIsPossible()    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        sendButtonAction(textField)
        return false
    }
    
    @objc func checkIfGenerationIsPossible() {
        let currentCount = textField.text?.count ?? 0
        generateButton.isEnabled = currentCount > 0 && currentCount < 1000
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let image = imageView.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        return [item]
    }

    fileprivate func resetView() {
        imageView.isUserInteractionEnabled = false
        imageView.image = #imageLiteral(resourceName: "Blank QR")
        textField.text = nil
        qrCodeImage = nil
        exportButton.isEnabled = false
    }
    
    @IBAction func sendButtonAction(_ sender: Any) {
        let qrData = textField.text
        textField.resignFirstResponder()
        
        if qrCodeImage == nil {
            if qrData == "" {
                return
            }
            hud.show(in: imageView)
            DispatchQueue.global(qos: .background).async {
                let result = self.generateQRCode(content: qrData!)
                DispatchQueue.main.async {
                    if let resultImage = result {
                        let newImage = self.convertCIImageToCGImage(inputImage: resultImage)
                        self.displayQRCodeImage(image: newImage!)
                    } else {
                        self.hud.dismiss()
                        return
                    }
                }
            }
        }
    }

    func generateQRCode(content: String) -> CIImage? {
        let data = content.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        
        let scale: CGFloat = 44
        
        print(filter.outputImage)
        print("content: \(content)")
        print("content length: \(content.count)")
        
        
        if let qrCode = filter.outputImage {
            return qrCode.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        } else {
            return nil
        }
    }
    
    func displayQRCodeImage(image: CGImage!) {
        imageView.image = UIImage(cgImage: image)
        imageView.isUserInteractionEnabled = true
        exportButton.isEnabled = true
        
        if firstAction {
            firstAction = false
            emptyLabel.removeFromSuperview()
        }
        hud.dismiss()
    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }
    
    // share image
    @IBAction func shareImageButton(_ sender: UIButton) {
        let image = imageView.image!
        
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}
