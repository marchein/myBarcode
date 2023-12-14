//
//  myBarcodeMatomo.swift
//  myBarcode
//
//  Created by Marc Hein on 01.06.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import Foundation
import MatomoTracker

struct myBarcodeMatomo {
    static func track(action: String, name: String, number: NSNumber? = nil) {
        let actionUrl = "\(matomoAppUrl)\(name.replacingOccurrences(of: "myBarcode-app-", with: ""))"
        let matomoActionUrl = URL(string: actionUrl)!
        MatomoTracker.shared.track(eventWithCategory: myBarcodeMatomo.categoryName, action: action, name: name, number: number, url: matomoActionUrl)
    }
    
    static let matomoAppUrl = "myBarcode://app/\(myBarcode.versionString)/"
    
    static let categoryName = "myBarcodeApp"
    
    static let basicAction = "Basic"
    static let settingsAction = "Settings"
    static let generateAction = "Generate"
    static let scanAction = "Scan"
    
    // MARK: - Basic Actions
    // app is started by user
    static let appStartAction = "myBarcode-app-started"
    // user opened plan view
    static let generateViewShown = "myBarcode-app-generate-shown"
    // user opened balance view
    static let scanViewShown = "myBarcode-app-scan-shown"
    
    // MARK: - Settings Actions
    // user opens settings
    static let settingsOpenAction = "myBarcode-app-settings"
    // user opens default app icon view in settings
    static let settingsAppIconAction = "myBarcode-app-settings-appicon"
    // user sets the default selected tab in settings
    static let settingsAppIconSetAction = "myBarcode-app-settings-appicon-set"
    // user opens default selected tab view in settings
    static let settingsDefaultTabAction = "myBarcode-app-settings-default-tab"
    // user sets the default selected tab in settings
    static let settingsDefaultTabSetAction = "myBarcode-app-settings-default-tab-set"
    // user opens default code view in settings
    static let settingsDefaultCodeAction = "myBarcode-app-settings-default-code"
    // user sets the default selected code in settings
    static let settingsDefaultCodeSetAction = "myBarcode-app-settings-default-code-set"
    // user sets switch to hide code selector
    static let settingsHideNonDefaultCodeSetAction = "myBarcode-app-settings-hide-non-default-code-set"
    // user sets switch to disable history
    static let settingsDisableHistorySetAction = "myBarcode-app-settings-disable-history-set"
    // user selected support in settings
    static let settingsSupportAction = "myBarcode-app-settings-support"
    // user selected appstore in settings
    static let settingsAppStoreAction = "myBarcode-app-settings-appstore"
    // user selected review in settings
    static let settingsReviewAction = "myBarcode-app-settings-review"
    // user selected recommend in settings
    static let settingsRecommendAction = "myBarcode-app-settings-recommend"
    // user selected about us in settings
    static let settingsAboutAction = "myBarcode-app-settings-about"
    // user selected privacy in settings
    static let settingsPrivacyAction = "myBarcode-app-settings-privacy"
    // user selected privacy notice in settings
    static let settingsPrivacyNoticeAction = "myBarcode-app-settings-privacynotice"
    // user selected about matomo in settings
    static let settingsMatomoAboutAction = "myBarcode-app-settings-matomo-about"
    // user set matomo opt out in settings
    static let settingsMatomoOptOutAction = "myBarcode-app-settings-matomo-optout"
    
    
    // MARK: - Generate Actions
    // user generates new code
    static let generateGeneratedCode = "myBarcode-app-generate-generated"
    // user generates new qr code
    static let generateGeneratedCodeQR = "myBarcode-app-generate-generated-QR"
    // user generates new aztec code
    static let generateGeneratedCodeAztec = "myBarcode-app-generate-generated-Aztec"
    // user generates new code128 code
    static let generateGeneratedCodeCode128 = "myBarcode-app-generate-generated-Code128"
    // user generates new pdf417 code
    static let generateGeneratedCodePDF417 = "myBarcode-app-generate-generated-PDF417"
    // user exports qr code
    static let generateExport = "myBarcode-app-generate-export"
    // user opens templates
    static let generateOpenTemplates = "myBarcode-app-generate-templates-opened"
    // user selected template X
    static let generateSelectedTemplate = "myBarcode-app-generate-templates-selected"
    // user reused template
    static let generateReusedTemplate = "myBarcode-app-generate-templates-reused"
    // user opened generate history
    static let generateHistory = "myBarcode-app-generate-history"
    // user selects item in generate history
    static let generateHistorySelected = "myBarcode-app-generate-history-deleted"
    // user deleted in generate history
    static let generateHistoryDeleted = "myBarcode-app-generate-history-deleted"
    
    // MARK: - Scan Actions
    // user scans code
    static let scanScannedCode = "myBarcode-app-scan-scanned"
    // user scans qr
    static let scanScannedCodeQR = "myBarcode-app-scan-scanned-qr"
    // user scans aztec
    static let scanScannedCodeAztec = "myBarcode-app-scan-scanned-aztec"
    // user scans code128
    static let scanScannedCodeCode128 = "myBarcode-app-scan-scanned-code128"
    // user scans pdf417
    static let scanScannedCodePDF417 = "myBarcode-app-scan-scanned-pdf417"
    // user selected images picker
    static let scanImagePickerOpened = "myBarcode-app-scan-image"
    // user scans qr code from image
    static let scanImageScanned = "myBarcode-app-scan-image-scanned"
    // user scans qr code from image
    static let scanImageScanFailed = "myBarcode-app-scan-image-scanned-failed"
    // user opened scan history
    static let scanHistory = "myBarcode-app-scan-history"
    // user selects item in scan history
    static let scanHistorySelected = "myBarcode-app-scan-history-deleted"
    // user deleted in scan history
    static let scanHistoryDeleted = "myBarcode-app-scan-history-deleted"
}
