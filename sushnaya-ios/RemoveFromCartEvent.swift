//
//  RemoveFromCart.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/18/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

struct RemoveFromCartEvent: Event {
    static var name: String = "\(RemoveFromCartEvent.self)"
    
    var product: Product
    var price: Price
    
    static func fire(product: Product, withPrice price: Price) {
        EventBus.post(RemoveFromCartEvent.name, sender: RemoveFromCartEvent(product: product, price: price))
    }
}
