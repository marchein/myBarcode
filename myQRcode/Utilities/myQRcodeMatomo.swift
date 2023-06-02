//
//  myQRcodeMatomo.swift
//  myQRcode
//
//  Created by Marc Hein on 01.06.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import Foundation
import MatomoTracker

struct myQRcodeMatomo {
    static func track(action: String, name: String, number: NSNumber? = nil) {
        let actionUrl = "\(matomoAppUrl)\(name.replacingOccurrences(of: "myQRcode-app-", with: ""))"
        let matomoActionUrl = URL(string: actionUrl)!
        MatomoTracker.shared.track(eventWithCategory: myQRcodeMatomo.categoryName, action: action, name: name, number: number, url: matomoActionUrl)
    }
    
    static let matomoAppUrl = "https://myqrcode.marc-hein.de/app/"
    
    static let categoryName = "myQRcodeApp"
    
    static let basicAction = "Basic"
    static let settingsAction = "Settings"
    static let generateAction = "Generate"
    static let scanAction = "Scan"
    
    // MARK: - Basic Actions
    // app is started by user
    static let appStartAction = "myQRcode-app-started"
    // user opened plan view
    static let generateViewShown = "myQRcode-app-generate-shown"
    // user opened balance view
    static let scanViewShown = "myQRcode-app-scan-shown"
    
    // MARK: - Settings Actions
    // user opens settings
    static let settingsOpenAction = "myQRcode-app-settings"
    // user sets the default selected tab in settings
    static let settingsSelectedTabAction = "myQRcode-app-settings-default-tab"
    // user selected support in settings
    static let settingsSupportAction = "myQRcode-app-settings-support"
    // user selected appstore in settings
    static let settingsAppStoreAction = "myQRcode-app-settings-appstore"
    // user selected review in settings
    static let settingsReviewAction = "myQRcode-app-settings-review"
    // user selected recommend in settings
    static let settingsRecommendAction = "myQRcode-app-settings-recommend"
    // user selected about us in settings
    static let settingsAboutAction = "myQRcode-app-settings-about"
    // user selected privacy in settings
    static let settingsPrivacyAction = "myQRcode-app-settings-privacy"
    // user selected privacy notice in settings
    static let settingsPrivacyNoticeAction = "myQRcode-app-settings-privacynotice"
    // user selected about matomo in settings
    static let settingsMatomoAboutAction = "myQRcode-app-settings-matomo-about"
    // user set matomo opt out in settings
    static let settingsMatomoOptOutAction = "myQRcode-app-settings-matomo-optout"
    
    
    // MARK: - Generate Actions
    // user generates new qr code
    static let generateGeneratedQR = "myQRcode-app-generate-generated"
    // user exports qr code
    static let generateExport = "myQRcode-app-generate-export"
    // user opens templates
    static let generateOpenTemplates = "myQRcode-app-generate-templates-opened"
    // user selected template X
    static let generateSelectedTemplate = "myQRcode-app-generate-templates-selected"
    // user reused template
    static let generateReusedTemplate = "myQRcode-app-generate-templates-reused"
    // user opened generate history
    static let generateHistory = "myQRcode-app-generate-history"
    // user selects item in generate history
    static let generateHistorySelected = "myQRcode-app-generate-history-deleted"
    // user deleted in generate history
    static let generateHistoryDeleted = "myQRcode-app-generate-history-deleted"
    
    // MARK: - Scan Actions
    // user scans qr code
    static let scanScannedQR = "myQRcode-app-scan-scanned"
    // user selected images picker
    static let scanImagePickerOpened = "myQRcode-app-scan-image"
    // user scans qr code from image
    static let scanImageScanned = "myQRcode-app-scan-image-scanned"
    // user opened scan history
    static let scanHistory = "myQRcode-app-scan-history"
    // user selects item in scan history
    static let scanHistorySelected = "myQRcode-app-scan-history-deleted"
    // user deleted in scan history
    static let scanHistoryDeleted = "myQRcode-app-scan-history-deleted"
}
