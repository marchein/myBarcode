//
//  ScanIntent.swift
//  ScanIntent
//
//  Created by Marc Hein on 16.09.24.
//  Copyright © 2024 Marc Hein. All rights reserved.
//

import AppIntents

@available(iOS 16.0, *)
struct ScanIntent: AppIntent {
    // Static properties for title and description using appropriate types
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "OPEN_MYBARCODE_SCANNER")
    static var description: IntentDescription = IntentDescription(stringLiteral: "OPEN_MYBARCODE_SCANNER_DESCRIPTION")
    
    static var openAppWhenRun: Bool = true
    
    // This is where the logic for the intent will be executed
    func perform() async throws -> some IntentResult {
       // Post a notification or signal that the scanner should be opened
       NotificationCenter.default.post(name: .startScanner, object: nil)
       
       return .result()
   }
}
