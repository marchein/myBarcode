//
//  HistoryItem+Date.swift
//  myQRcode
//
//  Created by Marc Hein on 16.08.20.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import Foundation

extension HistoryItem {
    
    @objc var isoDate: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            guard let date = self.date else {
                return ""
            }
            return formatter.string(from: date)
        }
    }
    
    @objc var isoTime: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            guard let date = self.date else {
                return ""
            }
            return formatter.string(from: date)
        }
    }
}
