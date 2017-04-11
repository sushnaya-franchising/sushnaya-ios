//
//  Cart.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/8/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

class CartItem {
    let product: Product
    let price: Price
    
    init(product: Product, price: Price) {
        self.product = product
        self.price = price
    }
}

class Cart: NSObject {
    private var items = [CartItem]()
    
    var sum: Price {
        var sumValue: CGFloat = 0
        // todo: use app default locale
        // todo: implement support for multicurrency
        let currencyLocale = items.count == 0 ? "ru_RU": items[0].price.currencyLocale
        
        items.forEach {
            assert(currencyLocale == $0.price.currencyLocale)
            
            sumValue = sumValue + $0.price.value
        }
        
        return Price(value: sumValue, currencyLocale: currencyLocale)
    }
    
    func push(product: Product, withPrice price: Price) {
        push(cartItem: CartItem(product: product, price: price))
    }
    
    func push(cartItem: CartItem) {
        items.append(cartItem)
        
        DidAddToCart.fire(cart: self, cartItem: cartItem)
    }
    
    func pop() -> (Product, Price)? {
        guard let cartItem = items.popLast() else {
            return nil
        }
        
        DidRemoveFromCart.fire(cart: self, cartItem: cartItem)
        
        return (cartItem.product, cartItem.price)
    }
}
