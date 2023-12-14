//
//  Aztec.swift
//  myBarcode
//
//  Created by Marc Hein on 14.08.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

class Aztec: Code, CustomStringConvertible {    
    static let generatorName = "CIAztecCodeGenerator"
    
    override class var maxLength: Int {
        return 3000
    }
    
    convenience init() {
        self.init(code: Code(content: "Placeholder", category: .generate))
    }
    
    override init(code: Code) {
        super.init(content: code.content, category: code.category, date: code.date)
        self.displayName = "Aztec"
        self.displayNameShort = self.displayName
        self.type = .AZTEC
    }
    
    
    
    override func generateImage() -> CIImage {
        let data = content.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let filter = CIFilter(name: Aztec.generatorName)!
        
        filter.setValue(data, forKey: "inputMessage")
        
        let scale: CGFloat = 44
        
        guard
            let output = filter.outputImage
        else {
            fatalError("Output image from CIFilter \(Aztec.generatorName) is nil!")
        }
        return output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    }
}
