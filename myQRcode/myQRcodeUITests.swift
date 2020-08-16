//
//  myQRcodeUITests.swift
//  myQRcodeUITests
//
//  Created by Marc Hein on 25.11.18.
//  Copyright © 2018 Marc Hein Webdesign. All rights reserved.
//

import XCTest

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

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        var identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        if identifier == "i386" || identifier == "x86_64" {
            identifier = getPlatformNSString()
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        default:                                        return identifier
        }
    }
    
}


class myQRcodeUITests: XCTestCase {
    
    var deviceScreenshotPath = ""
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        let screenshotPath = create(directory: "Screenshots/", root: "/Users/marchein/Projekte/")
        
        let deviceName = UIDevice.current.modelName
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
        print(url)
        
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
    
    func testScreenshotsEN() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
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
        app/*@START_MENU_TOKEN@*/.navigationBars["UIActivityContentView"]/*[[".otherElements[\"ActivityListView\"].navigationBars[\"UIActivityContentView\"]",".navigationBars[\"UIActivityContentView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["Close"].tap()
        app.tabBars.buttons["Scan"].tap()
        sleep(2)
        saveScreenshot(name: "05_scanner.jpeg")
        let image = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .image).element(boundBy: 1)
        image.tap()
        sleep(10)
        saveScreenshot(name: "06_scanner_result.jpeg")
        app.navigationBars["Result"].buttons["Close"].tap()
        app.navigationBars["Scan"].buttons["About"].tap()
        sleep(2)
        saveScreenshot(name: "07_scanner_history.jpeg")
        
        
    }
    
    func testScreenshotsDE() {
        let app = XCUIApplication()
        app.launch()
        saveScreenshot(name: "01_start.jpeg")
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.textFields["Inhalt des QR Codes"]/*[[".cells.textFields[\"Inhalt des QR Codes\"]",".textFields[\"Inhalt des QR Codes\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.textFields["Inhalt des QR Codes"].typeText("Inhalt Deines QR Codes")
        saveScreenshot(name: "02_entered.jpeg")
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["QR Code generieren"]/*[[".cells.buttons[\"QR Code generieren\"]",".buttons[\"QR Code generieren\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(3)
        saveScreenshot(name: "03_generated.jpeg")
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Generierten QR Code exportieren"]/*[[".cells.buttons[\"Generierten QR Code exportieren\"]",".buttons[\"Generierten QR Code exportieren\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
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
        
        let app = XCUIApplication()
        app.tabBars.buttons["Scannen"].tap()
        app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).children(matching: .scrollView).element(boundBy: 1).children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .image).element(boundBy: 1).tap()
        
        let image = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .image).element(boundBy: 1)
        image.tap()
        sleep(10)
        saveScreenshot(name: "06_scanner_result.jpeg")
        app.navigationBars["Ergebnis"].buttons["Schließen"].tap()
        app.navigationBars["Scannen"].buttons["History"].tap()
        sleep(2)
        saveScreenshot(name: "07_scanner_history.jpeg")
    }
}
