//
//  GenerateIntent.swift
//  GenerateIntent
//
//  Created by Marc Hein on 16.09.24.
//  Copyright © 2024 Marc Hein. All rights reserved.
//

import AppIntents

@available(iOS 16.0, *)
struct GenerateIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource(stringLiteral: "OPEN_MYBARCODE_GENERATOR")
    static var description: IntentDescription = IntentDescription(stringLiteral: "OPEN_MYBARCODE_GENERATOR_DESCRIPTION")

    static var openAppWhenRun: Bool = true
    
    // This is where the logic for the intent will be executed
    func perform() async throws -> some IntentResult {
       // Post a notification or signal that the scanner should be opened
        NotificationCenter.default.post(name: .startGenerator, object: nil)
       
       return .result()
   }
}
