//
//  Constants.swift
//  myBarcode
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import Foundation
import UIKit

struct localStoreKeys {
    // is app setup?
    static let appSetup = "appSetup"
    // is beta tester?
    static let isTester = "isTester"
    // has tipped?
    static let hasTipped = "hasTipped"
    // which is the current App icon?
    static let currentAppIcon = "currentIcon"
    // how many actions are taken
    static let codeGenerated = "codeGenerated"
    static let codeScanned = "codeScanned"
    
    static let defaultTab = "defaultSelectedTab"
    
    static let showOnlyDefaultCode = "showOnlyDefaultCode"
    static let defaultCode = "defaultSelectedCode"
    
    static let historyDisabled = "historyDisabled"
}

// MARK: - Cells
struct Cells {
    static let GenerateCell = "generateCell"
    static let TemplateCell = "templateCell"
    static let AppIconCell  = "appIcons"
    static let TipIntroCell = "introCell"
    static let TipCell      = "tipCell"
}

//MARK: - PossibleCodes
enum PossibleCodes: Int {
    case QR = 0
    case AZTEC = 1
    case CODE128 = 2
    case PDF417 = 3
}

//MARK: - TabOption
enum TabOption: Int {
    case GENERATE = 0
    case SCAN = 1
}

// MARK: - Segues
struct myBarcodeSegues {
    static let ResultSegue = "resultSegue"
    static let ShowHistorySegue = "showHistory"
    static let GenerateToTemplateSegue = "GenerateToTemplateSegue"
    static let EditTemplateSegue = "editTemplateSegue"
    static let ReuseTemplateSegue = "reuseTemplateSegue"
}

struct myBarcodeIAP {
    static let smallTip = "de.marc_hein.myQRcode.tip.small"
    static let mediumTip = "de.marc_hein.myQRcode.tip.medium"
    static let largeTip = "de.marc_hein.myQRcode.tip.large"
    static let xl = "de.marc_hein.myQRcode.tip.xl"
    
    static let allTips = [myBarcodeIAP.smallTip, myBarcodeIAP.mediumTip, myBarcodeIAP.largeTip, myBarcodeIAP.xl]
}

struct myBarcode {
    static let appStoreId = "1444531883"
    static let appStoreLink = "https://apps.apple.com/app/myqrcode/id1444531883"
    static let mailAdressDE = "help@mybarcode-app.de"
    static let mailAdressEN = "help@mybarcode-app.com"
    static let website = "https://marc-hein.de/"
    static let privacyNoticeEN = "https://myqrcode.marc-hein.de/privacy"
    static let privacyNoticeDE = "https://myqrcode.marc-hein.de/datenschutz"
    static let matomoWebsite = "https://matomo.org/faq/new-to-piwik/faq_13/"
   
    
    static let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    static let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String

    static let askForReviewAtSingleAction = 10
    static let askForReviewAtCombinedAction = 30
    
    static let tabValues: [TabOption: String] = [
        .GENERATE: "TAB_GENERATE".localized,
        .SCAN: "TAB_SCAN".localized
    ]
    
    static let codeValues: [PossibleCodes: String] = [
        .QR: "QR",
        .CODE128: "Code128",
        .PDF417: "PDF417",
        .AZTEC: "Aztec"
    ]
    
    static let codeStrings: [String: PossibleCodes] = [
        "QR": .QR,
        "Code128": .CODE128,
        "PDF417": .PDF417,
        "Aztec": .AZTEC
    ]
}

