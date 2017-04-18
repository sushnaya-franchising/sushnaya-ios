//
//  DidAddToCart.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/11/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

struct DidAddToCartEvent: Event {
    static var name: String = "\(DidAddToCartEvent.self)"
    
    var cart: Cart
    var cartItem: CartItem
    
    static func fire(cart: Cart, cartItem: CartItem) {
        EventBus.post(DidAddToCartEvent.name, sender: DidAddToCartEvent(cart: cart, cartItem: cartItem))
    }
}
