//
//  Constants.swift
//  myQRcode
//
//  Created by Marc Hein on 20.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
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
}

struct myQRcodeIAP {
    static let smallTip = "de.marc_hein.myQRcode.tip.small"
    static let mediumTip = "de.marc_hein.myQRcode.tip.medium"
    static let largeTip = "de.marc_hein.myQRcode.tip.large"
    static let xl = "de.marc_hein.myQRcode.tip.xl"
    
    static let allTips = [myQRcodeIAP.smallTip, myQRcodeIAP.mediumTip, myQRcodeIAP.largeTip, myQRcodeIAP.xl]
}

struct myQRcode {
    static let appStoreId = "1444531883"
    static let mailAdress = "dev@marc-hein.de"
    static let website = "https://marc-hein.de/"
    static let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    static let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    static let defaultAppIcon = "default"
    static var appIcons = AppIcons(icons: [
        AppIcon(iconName: nil, iconTitle: "myQRcode - \(NSLocalizedString("light_icon", comment: ""))"),
        AppIcon(iconName: "myQRcode-dark", iconTitle: "myQRcode - \(NSLocalizedString("dark_icon", comment: ""))")
    ])

    static let askForReviewAtSingleAction = 10
    static let askForReviewAtCombinedAction = 30
}

