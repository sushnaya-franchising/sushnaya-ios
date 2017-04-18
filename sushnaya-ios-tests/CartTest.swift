//
//  sushnaya_ios_tests.swift
//  sushnaya-ios-tests
//
//  Created by Igor Kurylenko on 4/18/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import XCTest
@testable import sushnaya_ios
import PromiseKit

class CartTest: XCTestCase {
    
    var cart: Cart!
    
    var product1: Product!
    var product2: Product!
    var product3: Product!
    var product4: Product!
    
    override func setUp() {
        super.setUp()
        
        cart = (UIApplication.shared.delegate as! App).userSession.cart
        
        product1 = Product(title: "p1",
                           pricing: [Price(value: 120, currencyLocale: "ru_RU")],
                           category: MenuCategory(title: "c1"))
        product2 = Product(title: "p2",
                           pricing: [Price(value: 240, currencyLocale: "ru_RU")],
                           category: MenuCategory(title: "c2"))
        product3 = Product(title: "p3",
                           pricing: [Price(value: 360, currencyLocale: "ru_RU")],
                           category: MenuCategory(title: "c3"))
        product4 = Product(title: "p4",
                           pricing: [Price(value: 360, currencyLocale: "ru_RU")],
                           category: MenuCategory(title: "c2"))
    }
    
    override func tearDown() {
        cart = nil
        product1 = nil
        product2 = nil
        product3 = nil
        
        super.tearDown()
    }
    
    func testExample() {
        cart.add(product: product1, withPrice: product1.pricing[0])
        cart.add(product: product2, withPrice: product2.pricing[0])
        cart.add(product: product3, withPrice: product3.pricing[0])
        cart.add(product: product4, withPrice: product4.pricing[0])
        
        cart.remove()
        cart.remove()
        cart.remove()
        cart.remove()
        
        XCTAssertTrue(cart.sum.value == 0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
