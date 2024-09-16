//
//  GenerateBarcodeControl.swift
//  GenerateBarcodeControl
//
//  Created by Marc Hein on 16.09.24.
//  Copyright © 2024 Marc Hein. All rights reserved.
//

import SwiftUI
import WidgetKit


@available(iOS 18.0, *)
struct GenerateBarcodeControl: ControlWidget {
    let kind: String = "de.marc-hein.myQRcode.GenerateBarcodeControl"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: kind) {
            ControlWidgetButton(action: GenerateIntent()) {
                Label("GENERATE_BARCODE".localized, systemImage: "barcode")
            }
        }
        .displayName(LocalizedStringResource(stringLiteral: "GENERATE_BARCODE".localized))
    }
}
