//
//  QRCode.swift
//  myBarcode
//
//  Created by Marc Hein on 16.08.20.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

class QRCode: Code, CustomStringConvertible {
    static let generatorName = "CIQRCodeGenerator"
    
    override class var maxLength: Int {
        return 2000
    }
    
    convenience init() {
        self.init(code: Code(content: "Placeholder", category: .generate))
    }
    
    override init(code: Code) {
        super.init(content: code.content, category: code.category, date: code.date)
        self.displayName = "QR-Code"
        self.displayNameShort = "QR"
        self.type = PossibleCodes.QR
    }
    
    
    
    override func generateImage() -> CIImage {
        let data = content.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let filter = CIFilter(name: QRCode.generatorName)!
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        
        let scale: CGFloat = 44
        
        guard
            let output = filter.outputImage
        else {
            fatalError("Output image from CIFilter CIQRCodeGenerator is nil!")
        }
        return output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    }
}
