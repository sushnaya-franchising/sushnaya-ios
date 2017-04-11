//
//  DidRemoveFromCart.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/11/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

struct DidRemoveFromCart: Event {
    static var name: String = "\(DidRemoveFromCart.self)"
    
    var cart: Cart
    var cartItem: CartItem
    
    static func fire(cart: Cart, cartItem: CartItem) {
        EventBus.post(DidRemoveFromCart.name, sender: DidRemoveFromCart(cart: cart, cartItem: cartItem))
    }
}
