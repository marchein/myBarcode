//
//  ScanBarcodeControl.swift
//  ScanBarcodeControl
//
//  Created by Marc Hein on 16.09.24.
//  Copyright © 2024 Marc Hein. All rights reserved.
//

import SwiftUI
import WidgetKit


@available(iOS 18.0, *)
struct ScanBarcodeControl: ControlWidget {
    let kind: String = "de.marc-hein.myQRcode.ScanBarcodeControl"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: kind) {
            ControlWidgetButton(action: ScanIntent()) {
                Label("SCAN_BARCODE".localized, systemImage: "qrcode.viewfinder")
            }
        }
        .displayName(LocalizedStringResource(stringLiteral: "SCAN_BARCODE".localized))
    }
}
