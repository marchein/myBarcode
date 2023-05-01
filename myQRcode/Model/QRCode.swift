//
//  QRCode.swift
//  myQRcode
//
//  Created by Marc Hein on 16.08.20.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

class QRCode: CustomStringConvertible {
    let content: String
    let category: HistoryCategory
    let date: Date
    
    init(content: String, category: HistoryCategory, date: Date = Date()) {
        self.content = content
        self.category = category
        self.date = date
    }
    
    func generateImage() -> CIImage {
        let data = content.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        
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
    
    var description: String {
        return "content=\(content), category=\(category), date=\(date)"
    }
}

enum HistoryCategory {
    case generate
    case scan
}
