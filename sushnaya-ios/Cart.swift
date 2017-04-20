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
        if let idx = findRow(cartItem: cartItem) {
            items[idx].append(cartItem)
        
        } else {
            items.append([cartItem])
        }
    }
    
    func removeCartItem(cartItem: CartItem) {
        for i in items.indices {
            for j in items[i].indices.reversed() where items[i][j] == cartItem {
                items[i].remove(at: j)
                if items[i].isEmpty {
                    items.remove(at: i)
                }
                return
            }
        }
    }
    
    private func findRow(cartItem: CartItem) -> Int? {
        return items.index(where: {$0[0].product == cartItem.product && $0[0].price == cartItem.price})
    }
}

class CartItem: Hashable {
    let id: Int
    let product: Product
    let price: Price
    
    var categoryTitle: String {
        return product.categoryTitle
    }
    
    fileprivate init(id: Int, product: Product, price: Price) {
        self.id = id
        self.product = product
        self.price = price
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
    
    private var counter:Int = 0
    private var history = [CartItem]()
    private(set) var cartSections = [CartSection]()
    
    var isEmpty:Bool {
        return history.isEmpty
    }
    
    var sum: Price {
        var sumValue: CGFloat = 0
        // todo: use app default locale
        // todo: implement support for multicurrency
        let currencyLocale = history.count == 0 ? "ru_RU": history[0].price.currencyLocale
        
        history.forEach {
            assert(currencyLocale == $0.price.currencyLocale)
            
            sumValue = sumValue + $0.price.value
        }
        
        return Price(value: sumValue, currencyLocale: currencyLocale)
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
            guard let event = (notification.object as? RemoveFromCartEvent) else {
                return
            }
            
            if let product = event.product, let price = event.price {                
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
        add(cartItem: CartItem(id: counter, product: product, price: price))
        
        counter += 1
    }
    
    private func add(cartItem: CartItem) {
        history.append(cartItem)
        
        addToCartSection(cartItem: cartItem)
        
        DidAddToCartEvent.fire(cart: self, cartItem: cartItem)
    }

    func remove() {
        guard let cartItem = history.popLast() else {
            return
        }
        
        removeFromCartSection(cartItem: cartItem)
        
        DidRemoveFromCartEvent.fire(cart: self, cartItem: cartItem)
    }
    
    func remove(product: Product, withPrice price: Price) {
        for idx in history.indices.reversed() where history[idx].product == product && history[idx].price == price {
            let cartItem = history.remove(at: idx)
            
            removeFromCartSection(cartItem: cartItem)
            
            DidRemoveFromCartEvent.fire(cart: self, cartItem: cartItem)
            
            break
        }
    }
    
    private func addToCartSection(cartItem: CartItem) {
        if let section = cartSections.filter({s in s.title == cartItem.categoryTitle}).first {
            section.appendCartItem(cartItem: cartItem)
            
        } else {
            let section = CartSection(title: cartItem.categoryTitle)
            section.appendCartItem(cartItem: cartItem)
            cartSections.append(section)
        }
    }
    
    private func removeFromCartSection(cartItem: CartItem) {
        let title = cartItem.product.categoryTitle
        
        if let cartSection = getSection(title: title) {
            cartSection.removeCartItem(cartItem: cartItem)
            
            if cartSection.items.isEmpty {
                removeSection(title: title)
            }
        }
    }
    
    private func removeSection(title: String) {
        if let idx = cartSections.index(where: {$0.title == title}) {
            cartSections.remove(at: idx)
        }
    }
    
    private func getSection(title: String) -> CartSection? {
        return cartSections.filter{$0.title == title}.first
    }
}
