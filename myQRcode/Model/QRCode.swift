//
//  QRCode.swift
//  myQRcode
//
//  Created by Marc Hein on 16.08.20.
//  Copyright © 2020 Marc Hein Webdesign. All rights reserved.
//

import UIKit

class QRCode {
    let content: String
    let category: HistoryCategory
    let date: Date
    var image: UIImage?
    var imageString: String? {
        get {
            return image?.toBase64()
        }
        
        set {
            if let newValue = newValue {
                let imageData = Data(base64Encoded: newValue, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
                self.image = UIImage(data: imageData)!
            }
        }
    }
    
    init(content: String, category: HistoryCategory, date: Date = Date(), imageString: String? = nil, image: UIImage? = nil) {
        self.content = content
        self.category = category
        self.date = date
        self.imageString = imageString
        self.image = image
        
        self.generateQRCode(content: self.content)
        DispatchQueue.main.async {
            self.generateCoreDataItem()
        }
    }
    
    func generateQRCode(content: String) {
        let data = content.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        
        let scale: CGFloat = 44
        
        if let output = filter.outputImage {
            let qrCode = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            self.image = convertCIImageToUIImage(inputImage: qrCode)
        }
    }
    
    func generateCoreDataItem() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let newItem = HistoryItem(context: managedObjectContext)
        newItem.content = self.content
        newItem.date = self.date
        newItem.category = self.category == HistoryCategory.generate
        newItem.imageString = self.imageString
        print(newItem)
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

enum HistoryCategory {
    case generate
    case scan
}
