//
//  Code.swift
//  myBarcode
//
//  Created by Marc Hein on 14.08.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import UIKit

class Code {
    let content: String
    let category: HistoryCategory
    let date: Date
    var displayName: String = "Code"
    var displayNameShort: String = "Code Short Name"
    var type: PossibleCodes
    
    class var maxLength: Int {
        preconditionFailure("This method must be overridden")
    }
    
    init(content: String, category: HistoryCategory, date: Date = Date()) {
        self.content = content
        self.category = category
        self.date = date
        self.type = .QR
    }
    
    init(code: Code) {
        preconditionFailure("This method must be overridden")
    }
    
    func generateImage() -> CIImage {
        preconditionFailure("This method must be overridden")
    }
    
    var description: String {
        return "content=\(content), category=\(category), date=\(date)"
    }
}
