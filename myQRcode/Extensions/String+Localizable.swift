//
//  String+Localizable.swift
//  myQRcode
//
//  Created by Marc Hein on 03.02.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import Foundation
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func localized(comment: String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
    }
}
