//
//  YandexGeocoderTest.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/29/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import XCTest
@testable import sushnaya_ios
import PromiseKit
import Alamofire

class YandexGeocoderTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGeocodeByCoordinate() {
        let exp = expectation(description: "Yandex reverse geocoding: geocode by coordinate")
    
        let coordinate = CLLocationCoordinate2D(latitude: 55.758, longitude: 37.611)
        YandexGeocoder.requestAddress(coordinate: coordinate).then { address -> () in
            XCTAssertNotNil(address)
            XCTAssertEqual(address!.countryCode, "RU")
            XCTAssertEqual(address!.formatted, "Москва, Тверская улица, 7")
            
            exp.fulfill()
            
        }.catch{ _ in
        }
        
        wait(for: [exp], timeout: 10)
    }
    
    func testGeocodeByQuery() {
        let exp = expectation(description: "Yandex reverse geocoding: geocode by query")
        
        YandexGeocoder.requestAddress(query: "ярославль зеленцовская 11").then { address -> () in
            XCTAssertNotNil(address)
            XCTAssertEqual(address!.countryCode, "RU")
            XCTAssertEqual(address!.formatted, "Ярославль, Зеленцовская улица, 9")
            
            exp.fulfill()
            
            }.catch{ _ in
        }
        
        wait(for: [exp], timeout: 10)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
