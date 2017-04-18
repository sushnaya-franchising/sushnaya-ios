//
//  AddToCartEvent.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/18/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

struct AddToCartEvent: Event {
    static var name: String = "\(AddToCartEvent.self)"
    
    var product: Product
    var price: Price
    
    static func fire(product: Product, withPrice price: Price) {
        EventBus.post(AddToCartEvent.name, sender: AddToCartEvent(product: product, price: price))
    }
}
