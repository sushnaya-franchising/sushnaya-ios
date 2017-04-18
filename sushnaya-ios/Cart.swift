//
//  Cart.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/8/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AVFoundation

class CartSection {
    let title: String
    // todo: make it functional and immutable
    var items = [[CartItem]]()
    
    fileprivate init(title: String) {
        self.title = title
    }
    
    func appendCartItem(cartItem: CartItem) {
        if var (idx, row) = findRow(cartItem: cartItem) {
            row.append(cartItem)
            items[idx] = row
        
        } else {
            items.append([cartItem])
        }
    }
    
    private func findRow(cartItem: CartItem) -> (Int, [CartItem])? {
        return items.enumerated().filter({(_, item) in item[0].product == cartItem.product && item[0].price == cartItem.price}).first
    }
}

class CartItem: Hashable {
    let id: Int
    let product: Product
    let price: Price
    let dateAdded: Date
    
    fileprivate init(id: Int, product: Product, price: Price, dateAdded: Date) {
        self.id = id
        self.product = product
        self.price = price
        self.dateAdded = dateAdded
    }
    
    var hashValue: Int {
        var result = 1
        result = 31 &* id &+ id.hashValue
        result = 31 &* result &+ product.hashValue
        result = 31 &* result &+ price.hashValue
        
        return result
    }
}

func ==(lhs: CartItem, rhs: CartItem) -> Bool {
    if lhs === rhs {
        return true
    }
    
    return lhs.id == rhs.id &&
        lhs.product == rhs.product &&
        lhs.price == rhs.price
}

class Cart: NSObject {
    
    var _counter:Int = 0
    fileprivate var items = [CartItem]()
    
    var isEmpty:Bool {
        return items.isEmpty
    }
    
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
    
    private var _cartSections: [CartSection]!
    
    var cartSections: [CartSection] {
        if let cached = _cartSections {
            return cached
        }
        
        _cartSections = [CartSection]()
        
        for item in items {
            if let section = _cartSections.filter({s in s.title == item.product.categoryTitle}).first {
                section.appendCartItem(cartItem: item)
            
            } else {
                let section = CartSection(title: item.product.categoryTitle)
                section.appendCartItem(cartItem: item)
                _cartSections.append(section)
            }
        }
        
        return _cartSections
    }

    
    override init() {
        super.init()
        registerEventHandlers()
    }
    
    deinit {
        EventBus.unregister(self)
    }
    
    private func registerEventHandlers() {
        EventBus.onMainThread(self, name: AddToCartEvent.name) { [unowned self] (notification) in
            if let event = (notification.object as? AddToCartEvent) {
                self.add(product: event.product, withPrice: event.price)
            }
        }
        
        EventBus.onMainThread(self, name: RemoveFromCartEvent.name) { [unowned self] (notification) in
            if let event = (notification.object as? RemoveFromCartEvent),
                let product = event.product, let price = event.price {
                
                self.remove(product: product, withPrice: price)
                
            } else {
                self.remove()
            }
        }
        
        EventBus.onMainThread(self, name: DidAddToCartEvent.name) { _ in
            AudioServicesPlaySystemSound(1156)
        }
        
        EventBus.onMainThread(self, name: DidRemoveFromCartEvent.name) { _ in
            AudioServicesPlaySystemSound(1155)
        }
    }
    
    func add(product: Product, withPrice price: Price) {
        let existingItem = items.reversed().filter{ $0.product == product && $0.price == price }.first
        
        let dateAdded = existingItem?.dateAdded ?? Date()
        
        add(cartItem: CartItem(id: _counter, product: product, price: price, dateAdded: dateAdded))
        
        _counter = _counter + 1
    }
    
    private func add(cartItem: CartItem) {
        items.append(cartItem)
        
        _cartSections = nil
        
        DidAddToCartEvent.fire(cart: self, cartItem: cartItem)
    }

    func remove() {
        guard let cartItem = items.popLast() else {
            return
        }
        
        _cartSections = nil
        
        DidRemoveFromCartEvent.fire(cart: self, cartItem: cartItem)
    }
    
    func remove(product: Product, withPrice price: Price) {
        for idx in items.indices.reversed() where items[idx].product == product && items[idx].price == price {
            let cartItem = items.remove(at: idx)
            
            _cartSections = nil
            
            DidRemoveFromCartEvent.fire(cart: self, cartItem: cartItem)
            
            break
        }
    }
}
