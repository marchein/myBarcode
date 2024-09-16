//
//  BarcodeWidgetBundle.swift
//  BarcodeWidget
//
//  Created by JAM on 16.09.24.
//  Copyright © 2024 Marc Hein. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct BarcodeWidgetBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 18.0, *) {
            GenerateBarcodeControl()
            ScanBarcodeControl()
        }
        
    }
}
