//
//  DidRemoveFromCart.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/11/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

struct DidRemoveFromCartEvent: Event {
    static var name: String = "\(DidRemoveFromCartEvent.self)"
    
    var cart: Cart
    var cartItem: CartItem
    
    static func fire(cart: Cart, cartItem: CartItem) {
        EventBus.post(DidRemoveFromCartEvent.name, sender: DidRemoveFromCartEvent(cart: cart, cartItem: cartItem))
    }
}
