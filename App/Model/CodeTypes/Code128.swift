//
//  Code128.swift
//  myBarcode
//
//  Created by Marc Hein on 14.08.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

class Code128: Code, CustomStringConvertible {
    
    static let generatorName = "CICode128BarcodeGenerator"
    
    override class var maxLength: Int {
        return 48
    }

    convenience init() {
        self.init(code: Code(content: "Placeholder", category: .generate))
    }
    
    override init(code: Code) {
        super.init(content: code.content, category: code.category, date: code.date)
        self.displayName = "Code128"
        self.displayNameShort = self.displayName
        self.type = .CODE128
    }
    
    
    
    override func generateImage() -> CIImage {
        let data = content.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let filter = CIFilter(name: Code128.generatorName)!
        
        filter.setValue(data, forKey: "inputMessage")
        
        let scale: CGFloat = 44
        
        guard
            let output = filter.outputImage
        else {
            fatalError("Output image from CIFilter \(Code128.generatorName) is nil!")
        }
        return output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    }
}
