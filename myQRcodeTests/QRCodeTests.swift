//
//  myBarcodeTests.swift
//  myBarcodeTests
//
//  Created by Marc Hein on 07.02.23.
//  Copyright © 2023 Marc Hein. All rights reserved.
//

import XCTest

@testable import myBarcode

final class QRCodeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testQRCode() throws {
        
        let code = Code(content: "Xcode Testing", category: .generate)
        let qrCode = QRCode(code: code)
        
        let expectedContent = "Xcode Testing"
        let expectedCategory = HistoryCategory.generate
        
        
        XCTAssertEqual(expectedContent, qrCode.content, "Check contents match")
        XCTAssertEqual(expectedCategory, qrCode.category, "Check category matches")
        
        let resultImage = qrCode.generateImage()
        XCTAssertNotNil(resultImage)
    }

    func testPerformanceQRCode() throws {
        let code = Code(content: "Xcode Testing", category: .generate)
        let qrCode = QRCode(code: code)
        
        measure {
            let resultImage = qrCode.generateImage()
            XCTAssertNotNil(resultImage)
        }
    }
    
    func testPerformanceLargeQRCode() throws {
        let longString = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.   Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.   Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit"
        
        let code = Code(content: longString, category: .generate)
        let qrCode = QRCode(code: code)
        measure {
            let resultImage = qrCode.generateImage()
            XCTAssertNotNil(resultImage)
        }
    }

}
