//
//  TemplateTestClass.swift
//  myQRcodeTests
//
//  Created by Marc Hein on 07.02.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import XCTest

final class TemplateTests: XCTestCase {
    func testTemplateActions() throws {
        let copiedTemplate = (Model.Templates[0][1] as! Template).copy() as! Template
        XCTAssertNotNil(copiedTemplate)
        XCTAssertTrue(copiedTemplate == Model.Templates[0][1] as! Template)
    }
    
    func testWifiTemplate() throws {
        let wifiName = "Test Network 1234 !%&/()"
        let wifiPassword = "11735831216878134824"
        for option in ["nopass", "WEP", "WPA"] {
            let wifiTemplate = (Model.Templates[0][1] as! Template).copy() as! Template
            wifiTemplate.parameterValues[0] = option
            wifiTemplate.parameterValues[1] = wifiName
            wifiTemplate.parameterValues[2] = wifiPassword
            
            let expectedWifiResultString = "WIFI:T:\(option);S:\(wifiName);P:\(wifiPassword);;"
            XCTAssertEqual(wifiTemplate.resultString, expectedWifiResultString)
         }
        
    }
    
    func testMailTemplate() throws {
        let mailTemplate = Model.Templates[0][2] as! Template
        let mailAdress = "test@testmail.com"
        mailTemplate.parameterValues[0] = mailAdress
        let expectedMailResultString = "mailto:\(mailAdress)"
        XCTAssertEqual(mailTemplate.resultString, expectedMailResultString)
    }
    
    func testPhoneTemplate() throws {
        let phoneTemplate = Model.Templates[0][3] as! Template
        let phoneNumber = "+49123456789"
        phoneTemplate.parameterValues[0] = phoneNumber
        let expectedPhoneResultString = "tel:\(phoneNumber)"
        XCTAssertEqual(phoneTemplate.resultString, expectedPhoneResultString)
    }
    
    func testSmsTemplate() throws {
        let smsTemplate = Model.Templates[0][4] as! Template
        let smsNumber = "+49123456789"
        smsTemplate.parameterValues[0] = smsNumber
        let expectedSmsResultString = "sms:\(smsNumber)"
        XCTAssertEqual(smsTemplate.resultString, expectedSmsResultString)
    }
}
