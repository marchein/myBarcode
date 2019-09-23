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
}

struct myQRcodeIAP {
    static let smallTip = "de.marc_hein.myQRcode.tip.small"
    static let mediumTip = "de.marc_hein.myQRcode.tip.medium"
    static let largeTip = "de.marc_hein.myQRcode.tip.large"
    
    static let allTips = [myQRcodeIAP.smallTip, myQRcodeIAP.mediumTip, myQRcodeIAP.largeTip]
}

struct myQRcode {
    static let appStoreId = "1444531883"
    static let twitterName = "HeinWebdesign"
    static let mailAdress = "info@marc-hein-webdesign.de"
    static let website = "https://marc-hein-webdesign.de/"
    static let supportPage = "https://marc-hein-webdesign.de/#kontakt"
    static let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    static let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    static let defaultAppIcon = "default"
    static var appIcons = AppIcons(icons: [
        AppIcon(iconName: nil, iconTitle: "myQRcode (2018)"),
        AppIcon(iconName: "myQRcode-dark", iconTitle: "myQRcode - Dark (2019)")
    ])
    static let thanksItems = [
        ["header": "Frameworks",
         "items": [Thank(name: "IQKeyboardManager", url: "https://github.com/hackiftekhar/IQKeyboardManager"),
                   Thank(name: "JGProgressHUD", url: "https://github.com/JonasGessner/JGProgressHUD")]]]
}
