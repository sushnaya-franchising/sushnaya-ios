//
//  MoneyUtilTest.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 6/10/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import XCTest
@testable import sushnaya_ios

class CashCalculatorTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // todo: write correct unit test for CashCalculator        
        let cashCalculator = CashCalculator(faces: Constants.NominalValues,
                                            monetaryUnitCentsCount: 1)
        cashCalculator.getPossibleCashValues(price: 1223)?.forEach{ print("- \($0)") }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
