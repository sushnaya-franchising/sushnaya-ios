//
//  Cart.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/8/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AVFoundation

class Cart: NSObject {

    private var history = [CartUnit]()
    private var sections = [CartSection]()

    var sectionsCount: Int {
        return sections.count
    }

    var isEmpty: Bool {
        return history.isEmpty
    }

    var sum: Price {
        var sumValue: Double = 0
        // todo: use app default locale
        // todo: implement support for multicurrency
        let currencyLocale = history.count == 0 ? "ru_RU" : history[0].price.currencyLocale

        history.forEach {
            assert(currencyLocale == $0.price.currencyLocale)

            sumValue = sumValue + $0.price.value
        }

        return Price(value: sumValue, currencyLocale: currencyLocale, modifierName: nil)
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
        add(cartUnit: CartUnit(product: product, price: price))
    }

    private func add(cartUnit: CartUnit) {
        history.append(cartUnit)

        addToSection(cartUnit: cartUnit)
    }

    func remove() {
        guard let cartUnit = history.popLast() else {
            return
        }

        removeFromSection(cartUnit: cartUnit)
    }

    func remove(product: Product, withPrice price: Price) {
        guard let idx = history.reversed().index(where: { cartUnit in cartUnit.product == product && cartUnit.price == price }) else {
            return
        }

        let cartUnit = history.remove(at: idx.base - 1)

        removeFromSection(cartUnit: cartUnit)
    }

    private func addToSection(cartUnit: CartUnit) {
        if let sectionIdx = sections.index(where: { s in s.title == cartUnit.categoryName }) {
            let section = sections[sectionIdx]
            let productIdx = section.append(unit: cartUnit)

            DidAddToCartEvent.fire(cart: self, sectionIdx: sectionIdx, productIdx: productIdx)

        } else {
            let section = CartSection(title: cartUnit.categoryName ?? "")
            let productIdx = section.append(unit: cartUnit)
            let sectionIdx = sections.count
            sections.append(section)

            DidAddToCartEvent.fire(cart: self, sectionIdx: sectionIdx, productIdx: productIdx)
        }
    }

    private func removeFromSection(cartUnit: CartUnit) {
        guard let sectionIdx = sections.index(where: { section in section.title == cartUnit.categoryName }) else {
            return
        }

        let section = sections[sectionIdx]

        guard let (productIdx, allUnitsWasRemoved) = section.remove(cartUnit: cartUnit) else {
            return
        }

        if section.isEmpty {
            sections.remove(at: sectionIdx)

            DidRemoveFromCartEvent.fireSectionWasRemoved(sectionIdx: sectionIdx, inCart: self)

        } else if allUnitsWasRemoved {
            DidRemoveFromCartEvent.fireAllUnitsWasRemoved(
                    ofProduct: productIdx, inSection: sectionIdx, inCart: self)

        } else {
            DidRemoveFromCartEvent.fireUnitWasRemoved(ofProduct: productIdx, inSection: sectionIdx, inCart: self)
        }
    }

    subscript(sectionIdx: Int) -> CartSection {
        return sections[sectionIdx]
    }
}

class CartSection {
    let title: String
    // todo: make it immutable
    private var items = [CartItem]()

    var itemsCount: Int {
        return items.count
    }

    var isEmpty: Bool {
        return itemsCount == 0
    }

    init(title: String) {
        self.title = title
    }

    fileprivate func append(unit: CartUnit) -> Int {
        if let idx = findRow(forCartUnit: unit) {
            items[idx].append(unit: unit)

            return idx

        } else {
            items.append(CartItem(firstUnit: unit))

            return items.count - 1
        }
    }

    fileprivate func remove(cartUnit u: CartUnit) -> (Int, Bool)? {
        guard let itemIdx = items.index(where: { $0.product == u.product && $0.price == u.price }) else {
            return nil
        }

        items[itemIdx].remove(unit: u)

        let noMoreUnits = items[itemIdx].noMoreUnits
        if noMoreUnits {
            items.remove(at: itemIdx)
        }

        return (itemIdx, noMoreUnits)
    }

    private func findRow(forCartUnit u: CartUnit) -> Int? {
        return items.index(where: { $0.product == u.product && $0.price == u.price })
    }

    subscript(itemIdx: Int) -> CartItem {
        return items[itemIdx]
    }
}

class CartItem {
    private var units = [CartUnit]()

    let product: Product
    let price: Price

    var count: Int {
        return units.count
    }

    var noMoreUnits: Bool {
        return units.count == 0
    }

    var sum: Price {
        let initialResult = units[0].price

        return units.dropFirst().reduce(initialResult) {
            $0 + $1.price
        }
    }

    fileprivate init(firstUnit: CartUnit) {
        self.product = firstUnit.product
        self.price = firstUnit.price
        
        append(unit: firstUnit)
    }

    fileprivate func append(unit: CartUnit) {
        units.append(unit)
    }

    fileprivate func remove(unit: CartUnit) {
        guard let unitIdx = units.reversed().index(where: { $0 == unit }) else {
            return
        }

        units.remove(at: unitIdx.base - 1)
    }
}

fileprivate class CartUnit: Hashable {
    let id: String = UUID().uuidString
    let product: Product
    let price: Price
    var isConfirmed = false

    var categoryName: String? {
        return product.categoryName
    }

    init(product: Product, price: Price) {
        self.product = product
        self.price = price
    }

    var hashValue: Int {
        var result = 1
        result = 31 &* result &+ id.hashValue
        result = 31 &* result &+ product.hashValue
        result = 31 &* result &+ price.hashValue

        return result
    }
}

fileprivate func ==(lhs: CartUnit, rhs: CartUnit) -> Bool {
    if lhs === rhs {
        return true
    }

    return lhs.id == rhs.id &&
            lhs.product == rhs.product &&
            lhs.price == rhs.price
}
