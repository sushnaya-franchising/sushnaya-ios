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
    let countedItems: [(CartItem, Int)]
    
    fileprivate init(title: String, countedItems: [(CartItem, Int)]) {
        self.title = title
        self.countedItems = countedItems
    }
}

class CartItem: Hashable {
    let product: Product
    let price: Price
    var dateAdded: Date
    
    fileprivate init(product: Product, price: Price, dateAdded: Date) {
        self.product = product
        self.price = price
        self.dateAdded = dateAdded
    }
    
    var hashValue: Int {
        var result = 1
        result = 31 &* result &+ product.hashValue
        result = 31 &* result &+ price.hashValue
        
        return result
    }
}

func ==(lhs: CartItem, rhs: CartItem) -> Bool {
    if lhs === rhs {
        return true
    }
    
    return lhs.product == rhs.product &&
        lhs.price == rhs.price
}

class Cart: NSObject {
    fileprivate var items = [CartItem]()
    
    private var _cartSections: [CartSection]!
    
    var cartSections: [CartSection] {
        if let cached = _cartSections {
            return cached
        }
        
        _cartSections = [CartSection]()
        
        for (categoryTitle, items) in groupItemsByCategoryTitle() {
            let countedItems = countEqualItems(items).sorted { $0.0.dateAdded < $1.0.dateAdded }
            
            _cartSections.append(CartSection(title: categoryTitle, countedItems: countedItems))
        }
        
        _cartSections = _cartSections!.sorted { $0.countedItems[0].0.dateAdded < $1.countedItems[0].0.dateAdded }
        
        return _cartSections
    }
    
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
                self.push(product: event.product, withPrice: event.price)
            }
        }
        
        EventBus.onMainThread(self, name: RemoveFromCartEvent.name) { [unowned self] (notification) in
            if let event = (notification.object as? RemoveFromCartEvent) {
                self.remove(product: event.product, withPrice: event.price)
            }
        }
        
        EventBus.onMainThread(self, name: PopCartItemEvent.name) { [unowned self] _ in
            self.pop()
        }
        
        EventBus.onMainThread(self, name: DidAddToCartEvent.name) { _ in
            AudioServicesPlaySystemSound(1156)
        }
        
        EventBus.onMainThread(self, name: DidRemoveFromCartEvent.name) { _ in
            AudioServicesPlaySystemSound(1155)
        }
    }

    
    private func push(product: Product, withPrice price: Price) {
        let existingItem = items.reversed().filter{ $0.product == product && $0.price == price }.first
        
        let dateAdded = existingItem?.dateAdded ?? Date()
        
        push(cartItem: CartItem(product: product, price: price, dateAdded: dateAdded))
    }
    
    private func push(cartItem: CartItem) {
        items.append(cartItem)
        
        _cartSections = nil
        
        DidAddToCartEvent.fire(cart: self, cartItem: cartItem)
    }
    
    @discardableResult private func pop() -> (Product, Price)? {
        guard let cartItem = items.popLast() else {
            return nil
        }
        
        _cartSections = nil
        
        DidRemoveFromCartEvent.fire(cart: self, cartItem: cartItem)
        
        return (cartItem.product, cartItem.price)
    }
    
    private func remove(product: Product, withPrice price: Price) {
        // todo: implement
    }
}

extension Cart {
    fileprivate func groupItemsByCategoryTitle() -> [String: [CartItem]] {
        var itemsByCategoryTitle = [String: [CartItem]]()
        for item in items {
            let categoryTitle = item.product.categoryTitle
            var categoryItems = itemsByCategoryTitle[categoryTitle] ?? [CartItem]()
            
            categoryItems.append(item)
            
            itemsByCategoryTitle[categoryTitle] = categoryItems
        }

        return itemsByCategoryTitle
    }
    
    fileprivate func countEqualItems(_ items: [CartItem]) -> [(CartItem, Int)] {
        var countedItems = [CartItem: Int]()
        for item in items {
            let count = (countedItems[item] ?? 0) + 1
            countedItems[item] = count
        }
        
        return countedItems.map{($0, $1)}
    }
}
