//
//  myBarcodeUITests.swift
//  myBarcodeUITests
//
//  Created by Marc Hein on 13.12.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import XCTest

final class myBarcodeUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    let codeValues: [String] = [
        "QR",
        "Code128",
        "PDF417",
        "Aztec"
    ]
    
    func testGenerate() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        let testString = "Test Content §$%&/("
        let tablesQuery = app.tables
        
        for (name) in codeValues {
            let actualTestString = testString + name
            print("Value: \(name)")
            // You can now use 'code' and 'value' in each iteration
            if !tablesQuery.buttons[name].exists {
                return;
            }
            tablesQuery.buttons[name].tap()
            let codeContentField = tablesQuery.textViews["codeContent"]
            codeContentField.tap()
            codeContentField.typeText(actualTestString)
            tablesQuery.staticTexts["Code generieren"].tap()
            tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Teilen"]/*[[".cells",".buttons[\"Teilen\"].staticTexts[\"Teilen\"]",".staticTexts[\"Teilen\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
            app.collectionViews.cells["Bild sichern"].children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 2).tap()
            if app.alerts["„myBarcode“ möchte Fotos hinzufügen."].exists {
                app.alerts["„myBarcode“ möchte Fotos hinzufügen."].scrollViews.otherElements.buttons["Erlauben"].tap()
            }
            
            
            if tablesQuery/*@START_MENU_TOKEN@*/.buttons["Schließen"]/*[[".cells.buttons[\"Schließen\"]",".buttons[\"Schließen\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists {
                tablesQuery/*@START_MENU_TOKEN@*/.buttons["Schließen"]/*[[".cells.buttons[\"Schließen\"]",".buttons[\"Schließen\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            }
        }
    }
    
    func testGenerateAndScanQR() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        let testString = "Test Content §$%&/("
        let tablesQuery = app.tables
        let name = "QR"
        let actualTestString = testString + name
        if !tablesQuery.buttons[name].exists {
            return;
        }
        tablesQuery.buttons[name].tap()
        let codeContentField = tablesQuery.textViews["codeContent"]
        codeContentField.tap()
        codeContentField.typeText(actualTestString)
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Code generieren"]/*[[".cells",".buttons[\"Code generieren\"].staticTexts[\"Code generieren\"]",".staticTexts[\"Code generieren\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Teilen"]/*[[".cells",".buttons[\"Teilen\"].staticTexts[\"Teilen\"]",".staticTexts[\"Teilen\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.collectionViews.cells["Bild sichern"].children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 2).tap()
        if app.alerts["„myBarcode“ möchte Fotos hinzufügen."].exists {
            app.alerts["„myBarcode“ möchte Fotos hinzufügen."].scrollViews.otherElements.buttons["Erlauben"].tap()
        }
        app.tabBars["Tab-Leiste"].buttons["Scannen"].tap()
        app.navigationBars["Scannen"].buttons["Bild auswählen"].tap()
        app.scrollViews.otherElements.images.element(boundBy: 0).tap()
        let res = tablesQuery.cells.children(matching: .textView).element.children(matching: .textView).firstMatch.label
        
        XCTAssertEqual(actualTestString, res)
        app.navigationBars["Ergebnis"].buttons["Schließen"].tap()
        
        
        let tabLeisteTabBar = XCUIApplication().tabBars["Tab-Leiste"]
        tabLeisteTabBar.buttons["Generieren"].tap()
    }
        
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
