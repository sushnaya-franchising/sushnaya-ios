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
    
    let cart: Cart
    let sectionIdx: Int
    let productIdx: Int
    
    static func fire(cart: Cart, sectionIdx: Int, productIdx: Int) {
        EventBus.post(DidAddToCartEvent.name, sender: DidAddToCartEvent(
                cart: cart, sectionIdx: sectionIdx, productIdx: productIdx))
    }
}
