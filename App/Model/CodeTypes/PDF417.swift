//
//  PDF417.swift
//  myBarcode
//
//  Created by Marc Hein on 14.08.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

class PDF417: Code, CustomStringConvertible {
    
    static let generatorName = "CIPDF417BarcodeGenerator"
    
    override class var maxLength: Int {
        return 1850
    }
    
    convenience init() {
        self.init(code: Code(content: "Placeholder", category: .generate))
    }
    
    override init(code: Code) {
        super.init(content: code.content, category: code.category, date: code.date)
        self.displayName = "PDF417"
        self.displayNameShort = self.displayName
        self.type = .PDF417
    }
    
    
    
    override func generateImage() -> CIImage {
        let data = content.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let filter = CIFilter(name: PDF417.generatorName)!
        
        filter.setValue(data, forKey: "inputMessage")
        
        let scale: CGFloat = 44
        
        guard
            let output = filter.outputImage
        else {
            fatalError("Output image from CIFilter \(PDF417.generatorName) is nil!")
        }
        return output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    }
}
