//
//  myQRcodeUITests.swift
//  myQRcodeUITests
//
//  Created by Marc Hein on 25.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import XCTest
import HeinHelpers
import SimulatorStatusMagic


func getPlatformNSString() -> String {
    #if targetEnvironment(simulator)
    let DEVICE_IS_SIMULATOR = true
    #else
    let DEVICE_IS_SIMULATOR = false
    #endif
    
    var machineSwiftString : String = ""
    
    if DEVICE_IS_SIMULATOR == true {
        // this neat trick is found at http://kelan.io/2015/easier-getenv-in-swift/
        if let dir = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            machineSwiftString = dir
        }
    }
    
    return machineSwiftString
}


class myQRCodeScreenshots: XCTestCase {
    
    var app: XCUIApplication!
    
    var deviceScreenshotPath = ""
    
    override func setUp() {
        super.setUp()
        
        SDStatusBarManager.sharedInstance().iPadDateEnabled = false
        SDStatusBarManager.sharedInstance().timeString = "9:41"
        SDStatusBarManager.sharedInstance().enableOverrides()
        continueAfterFailure = false
        app = XCUIApplication()
        let screenshotPath = create(directory: "Screenshots/", root: "/Users/marchein/Projekte/")
        
        let deviceName = UIDevice.modelName
        let deviceVersion = UIDevice.current.systemVersion
        
        deviceScreenshotPath = create(directory: deviceName + " - " + deviceVersion, root: screenshotPath)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        SDStatusBarManager.sharedInstance().disableOverrides()
    }
    
    func saveScreenshot(name: String) {
        let screenshot = XCUIScreen.main.screenshot().image
        let imageData =  screenshot.jpegData(compressionQuality: 1.0)!
        let url = URL(fileURLWithPath: deviceScreenshotPath + "/" + name)
        print(url.absoluteString)
        
        do {
            try imageData.write(to: url)
        } catch {
            print("Error while saving screenshot at: \(url.absoluteString)")
        }
    }
    
    func create(directory: String, root: String) -> String {
        let path = root + directory
        
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        
        return path
    }
    
    func testScreenshots() {
        if Locale.current.languageCode == "de" {
            createGermanScreenshots(darkMode: false)
            createGermanScreenshots(darkMode: true)
            return
        }
        createEnglishScreenshots(darkMode: false)
        createEnglishScreenshots(darkMode: true)
        
        /*
         Clean afterwards:
         rm 01_start_dark.jpeg 02_entered_light.jpeg 03_generated_dark.jpeg 04_shared_dark.jpeg 05_scanner_light.jpeg 06_scanner_result_dark.jpeg 07_scanner_history_dark.jpeg 08_templates_light.jpeg 09_templates_setup_dark.jpeg 10_templates_generated_dark.jpeg
         */
    }
    
    func createGermanScreenshots(darkMode: Bool = false) {
        if darkMode {
            app.launchArguments.append("UITestingDarkModeEnabled")
        }
        let mode = darkMode ? "dark" : "light"
        
        app.launch()
        
        saveScreenshot(name: "01_start_\(mode).jpeg")
        let tablesQuery = app.tables
        let qrCodeContentField = tablesQuery.textViews["qrCodeContent"]
        qrCodeContentField.tap()
        qrCodeContentField.typeText("myQRcode ist großartig!")
        tablesQuery.buttons["QR-Code generieren"].tap()
        sleep(3)
        saveScreenshot(name: "02_generated_\(mode).jpeg")
        tablesQuery.buttons["Generierten QR-Code exportieren"].tap()
        sleep(1)
        saveScreenshot(name: "03_shared_\(mode).jpeg")
        if app/*@START_MENU_TOKEN@*/.navigationBars["UIActivityContentView"]/*[[".otherElements[\"ActivityListView\"].navigationBars[\"UIActivityContentView\"]",".navigationBars[\"UIActivityContentView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["Schließen"].exists {
            app/*@START_MENU_TOKEN@*/.navigationBars["UIActivityContentView"]/*[[".otherElements[\"ActivityListView\"].navigationBars[\"UIActivityContentView\"]",".navigationBars[\"UIActivityContentView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["Schließen"].tap()
        } else {
            app.otherElements["PopoverDismissRegion"].tap()
        }
        app.tabBars.buttons["Scannen"].tap()
        sleep(2)
        saveScreenshot(name: "04_scanner_\(mode).jpeg")
        
        app.tabBars.buttons["Scannen"].tap()

        let items = app.images.allElementsBoundByAccessibilityElement
        
        app.images["demoImage"].tap()
        
        sleep(5)
        saveScreenshot(name: "05_scanner_result_\(mode).jpeg")
        app.navigationBars["Ergebnis"].buttons["Schließen"].tap()
        app.navigationBars["Scannen"].buttons["Verlauf"].tap()
                
        sleep(2)
        saveScreenshot(name: "06_scanner_history_\(mode).jpeg")
        app.navigationBars["Verlauf"].buttons["Schließen"].tap()

        app.tabBars.buttons["Generieren"].tap()
        
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Vorlagen"]/*[[".cells.staticTexts[\"Vorlagen\"]",".staticTexts[\"Vorlagen\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        saveScreenshot(name: "07_templates_\(mode).jpeg")
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["E-Mail Adresse"]/*[[".cells.staticTexts[\"E-Mail Adresse\"]",".staticTexts[\"E-Mail Adresse\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        saveScreenshot(name: "08_templates_setup_\(mode).jpeg")

        tablesQuery/*@START_MENU_TOKEN@*/.textFields["hello@placeholder.com"]/*[[".cells.textFields[\"hello@placeholder.com\"]",".textFields[\"hello@placeholder.com\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.textFields["hello@placeholder.com"].typeText("dev@marc-hein.de")
        
        tablesQuery.cells["generateQRCodeFromTemplateCell"].staticTexts.firstMatch.tap()
        sleep(2)
        saveScreenshot(name: "09_templates_generated_\(mode).jpeg")
        
        app.navigationBars["myQRcode"].buttons["Einstellungen"].tap()
        saveScreenshot(name: "10_settings_\(mode).jpeg")
        app.navigationBars["Einstellungen"].buttons["Schließen"].tap()
    }
    
    func createEnglishScreenshots(darkMode: Bool = false) {
        if darkMode {
            app.launchArguments.append("UITestingDarkModeEnabled")
        }
        let mode = darkMode ? "dark" : "light"
        app.launch()
        
        saveScreenshot(name: "01_start_\(mode).jpeg")
        let tablesQuery = app.tables
        let qrCodeContentField = tablesQuery.textViews["qrCodeContent"]
        qrCodeContentField.tap()
        qrCodeContentField.typeText("myQRcode is awesome!")
        //saveScreenshot(name: "02_entered_\(mode).jpeg")
        tablesQuery.buttons["Generate QR-code"].tap()
        sleep(3)
        saveScreenshot(name: "02_generated_\(mode).jpeg")
        tablesQuery.buttons["Export generated QR-code"].tap()
        sleep(1)
        saveScreenshot(name: "03_shared_\(mode).jpeg")
        if app/*@START_MENU_TOKEN@*/.navigationBars["UIActivityContentView"]/*[[".otherElements[\"ActivityListView\"].navigationBars[\"UIActivityContentView\"]",".navigationBars[\"UIActivityContentView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["Close"].exists {
            app/*@START_MENU_TOKEN@*/.navigationBars["UIActivityContentView"]/*[[".otherElements[\"ActivityListView\"].navigationBars[\"UIActivityContentView\"]",".navigationBars[\"UIActivityContentView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["Close"].tap()
        } else {
            app.otherElements["PopoverDismissRegion"].tap()
        }
        app.tabBars.buttons["Scan"].tap()
        sleep(2)
        saveScreenshot(name: "04_scanner_\(mode).jpeg")
        
        app.tabBars.buttons["Scan"].tap()

        let items = app.images.allElementsBoundByAccessibilityElement
        
        app.images["demoImage"].tap()
        
        sleep(5)
        saveScreenshot(name: "05_scanner_result_\(mode).jpeg")
        app.navigationBars["Result"].buttons["Close"].tap()
        app.navigationBars["Scan"].buttons["History"].tap()
                
        sleep(2)
        saveScreenshot(name: "06_scanner_history_\(mode).jpeg")
        app.navigationBars["History"].buttons["Close"].tap()

        app.tabBars.buttons["Generate"].tap()
        
        tablesQuery.staticTexts["Templates"].tap()
        saveScreenshot(name: "07_templates_\(mode).jpeg")
        tablesQuery.staticTexts["Email address"].tap()
        saveScreenshot(name: "08_templates_setup_\(mode).jpeg")

        tablesQuery/*@START_MENU_TOKEN@*/.textFields["hello@placeholder.com"]/*[[".cells.textFields[\"hello@placeholder.com\"]",".textFields[\"hello@placeholder.com\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.textFields["hello@placeholder.com"].typeText("dev@marc-hein.de")
        
        tablesQuery.cells["generateQRCodeFromTemplateCell"].staticTexts.firstMatch.tap()
        sleep(2)
        saveScreenshot(name: "09_templates_generated_\(mode).jpeg")
        
        app.navigationBars["myQRcode"].buttons["Settings"].tap()
        saveScreenshot(name: "10_settings_\(mode).jpeg")
        app.navigationBars["Settings"].buttons["Close"].tap()
        
    }

}


extension XCUIElement {
    // The following is a workaround for inputting text in the
    //simulator when the keyboard is hidden
    func setText(text: String, application: XCUIApplication) {
        UIPasteboard.general.string = text
        doubleTap()
        application.menuItems["Paste"].tap()
    }
}
