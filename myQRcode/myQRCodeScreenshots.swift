//
//  myQRcodeUITests.swift
//  myQRcodeUITests
//
//  Created by Marc Hein on 25.11.18.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import XCTest
import HeinHelpers

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
    
    var deviceScreenshotPath = ""
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        let screenshotPath = create(directory: "Screenshots/", root: "/Users/marchein/Projekte/")
        
        let deviceName = UIDevice.modelName
        let deviceVersion = UIDevice.current.systemVersion
        
        deviceScreenshotPath = create(directory: deviceName + " - " + deviceVersion, root: screenshotPath)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func saveScreenshot(name: String) {
        let screenshot = XCUIScreen.main.screenshot().image
        let imageData =  screenshot.jpegData(compressionQuality: 1.0)!
        let url = URL(fileURLWithPath: deviceScreenshotPath + "/" + name)
        HeinHelpers.logMessage(url.absoluteString)
        
        do {
            try imageData.write(to: url)
        } catch {
            HeinHelpers.logMessage("Error while saving screenshot at: \(url.absoluteString)")
        }
    }
    
    func create(directory: String, root: String) -> String {
        let path = root + directory
        
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            HeinHelpers.logMessage(error.localizedDescription);
        }
        
        return path
    }
    
    func testScreenshotsEN() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        XCUIDevice.shared.orientation = .landscapeRight

        let app = XCUIApplication()
        app.launch()
        let tablesQuery = app.tables
        saveScreenshot(name: "01_start.jpeg")
        tablesQuery/*@START_MENU_TOKEN@*/.textFields["Content of the QR code"]/*[[".cells.textFields[\"Content of the QR code\"]",".textFields[\"Content of the QR code\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.textFields["Content of the QR code"].typeText("Content of Your QR code")
        saveScreenshot(name: "02_entered.jpeg")
        app/*@START_MENU_TOKEN@*/.buttons["Done"]/*[[".keyboards",".buttons[\"Fertig\"]",".buttons[\"Done\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Generate QR code"]/*[[".cells.buttons[\"Generate QR code\"]",".buttons[\"Generate QR code\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(3)
        saveScreenshot(name: "03_generated.jpeg")
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Export generated QR code"]/*[[".cells.buttons[\"Export generated QR code\"]",".buttons[\"Export generated QR code\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(2)
        saveScreenshot(name: "04_shared.jpeg")
        if app/*@START_MENU_TOKEN@*/.navigationBars["UIActivityContentView"]/*[[".otherElements[\"ActivityListView\"].navigationBars[\"UIActivityContentView\"]",".navigationBars[\"UIActivityContentView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["Close"].exists {
            app/*@START_MENU_TOKEN@*/.navigationBars["UIActivityContentView"]/*[[".otherElements[\"ActivityListView\"].navigationBars[\"UIActivityContentView\"]",".navigationBars[\"UIActivityContentView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["Close"].tap()
        } else {
            app.otherElements["PopoverDismissRegion"].tap()
        }
        app.tabBars.buttons["Scan"].tap()
        sleep(2)
        saveScreenshot(name: "05_scanner.jpeg")
        
        app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .image).element.tap()
        
        sleep(10)
        saveScreenshot(name: "06_scanner_result.jpeg")
        app.navigationBars["Result"].buttons["Close"].tap()
        app.navigationBars["Scan"].buttons["About"].tap()
        sleep(2)
        saveScreenshot(name: "07_scanner_history.jpeg")
    }
    
    func testScreenshotsDE() {
        //         XCUIDevice.shared.orientation = .landscapeRight

        
        let app = XCUIApplication()
        app.launch()
        saveScreenshot(name: "01_start.jpeg")
        let tablesQuery = app.tables
        tablesQuery.textFields["Inhalt des QR-Codes"].tap()
        tablesQuery.textFields["Inhalt des QR-Codes"].typeText("Inhalt Deines QR Codes")
        saveScreenshot(name: "02_entered.jpeg")
        tablesQuery.buttons["QR-Code generieren"].tap()
        sleep(3)
        saveScreenshot(name: "03_generated.jpeg")
        tablesQuery.buttons["Generierten QR-Code exportieren"].tap()
        sleep(1)
        saveScreenshot(name: "04_shared.jpeg")
        if app/*@START_MENU_TOKEN@*/.navigationBars["UIActivityContentView"]/*[[".otherElements[\"ActivityListView\"].navigationBars[\"UIActivityContentView\"]",".navigationBars[\"UIActivityContentView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["Schließen"].exists {
            app/*@START_MENU_TOKEN@*/.navigationBars["UIActivityContentView"]/*[[".otherElements[\"ActivityListView\"].navigationBars[\"UIActivityContentView\"]",".navigationBars[\"UIActivityContentView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["Schließen"].tap()
        } else {
            app.otherElements["PopoverDismissRegion"].tap()
        }
        app.tabBars.buttons["Scannen"].tap()
        sleep(2)
        saveScreenshot(name: "05_scanner.jpeg")
        
        app.tabBars.buttons["Scannen"].tap()

        app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .image).element.tap()
        
        sleep(5)
        saveScreenshot(name: "06_scanner_result.jpeg")
        app.navigationBars["Ergebnis"].buttons["Schließen"].tap()
        app.navigationBars["Scannen"].buttons["Verlauf"].tap()
                
        sleep(2)
        saveScreenshot(name: "07_scanner_history.jpeg")
        app.navigationBars["Verlauf"].buttons["Schließen"].tap()

        app.tabBars["Tab-Leiste"].buttons["Generieren"].tap()
        
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Vorlagen"]/*[[".cells.staticTexts[\"Vorlagen\"]",".staticTexts[\"Vorlagen\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        saveScreenshot(name: "08_templates.jpeg")
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["E-Mail Adresse"]/*[[".cells.staticTexts[\"E-Mail Adresse\"]",".staticTexts[\"E-Mail Adresse\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        saveScreenshot(name: "09_templates_setup.jpeg")

        tablesQuery/*@START_MENU_TOKEN@*/.textFields["hello@placeholder.com"]/*[[".cells.textFields[\"hello@placeholder.com\"]",".textFields[\"hello@placeholder.com\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.textFields["hello@placeholder.com"].typeText("dev@marc-hein.de")
        
        tablesQuery.cells["generateQRCodeFromTemplateCell"].staticTexts.firstMatch.tap()
        sleep(2)
        saveScreenshot(name: "10_templates_generated.jpeg")
    }
    
    func testNewScreenshotsEN() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.textFields["Content of the QR code"]/*[[".cells.textFields[\"Content of the QR code\"]",".textFields[\"Content of the QR code\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Continue"]/*[[".otherElements[\"UIContinuousPathIntroductionView\"]",".buttons[\"Continue\"].staticTexts[\"Continue\"]",".staticTexts[\"Continue\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Generate QR code"]/*[[".cells.buttons[\"Generate QR code\"]",".buttons[\"Generate QR code\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let historyButton = app.navigationBars["myQRcode"].buttons["History"]
        historyButton.tap()
        app.navigationBars["History"].buttons["Close"].tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Templates"]/*[[".cells.staticTexts[\"Templates\"]",".staticTexts[\"Templates\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["WiFi login data"]/*[[".cells.staticTexts[\"WiFi login data\"]",".staticTexts[\"WiFi login data\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.children(matching: .cell).element(boundBy: 1).children(matching: .textField).element.tap()
        tablesQuery.children(matching: .cell).element(boundBy: 2).children(matching: .textField).element.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Generate QR code"]/*[[".cells.staticTexts[\"Generate QR code\"]",".staticTexts[\"Generate QR code\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        historyButton.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["WIFI:T:WPA;S:Wifi name;P:password123;;"]/*[[".cells.staticTexts[\"WIFI:T:WPA;S:Wifi name;P:password123;;\"]",".staticTexts[\"WIFI:T:WPA;S:Wifi name;P:password123;;\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
                
    }
}
