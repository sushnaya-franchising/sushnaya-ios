import Foundation

struct AddToCartEvent: Event {
    static var name: String = "\(AddToCartEvent.self)"
    
    var product: Product
    var price: Price
    
    static func fire(product: Product, withPrice price: Price) {
        EventBus.post(AddToCartEvent.name, sender: AddToCartEvent(product: product, price: price))
    }
}

struct RemoveFromCartEvent: Event {
    static var name: String = "\(RemoveFromCartEvent.self)"
    
    var product: Product?
    var price: Price?
    
    static func fire() {
        EventBus.post(RemoveFromCartEvent.name, sender: RemoveFromCartEvent(product: nil, price: nil))
    }
    
    static func fire(product: Product, withPrice price: Price) {
        EventBus.post(RemoveFromCartEvent.name, sender: RemoveFromCartEvent(product: product, price: price))
    }
}

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

protocol RemoveContext {
    var cart: Cart { get }
}

struct RemoveUnitContext: RemoveContext {
    var cart: Cart
    var sectionIdx: Int
    var productIdx: Int
    var allUnitsWasRemoved: Bool
}

struct RemoveSectionContext: RemoveContext {
    var cart: Cart
    var sectionIdx: Int
}

struct DidRemoveFromCartEvent: Event {
    static var name: String = "\(DidRemoveFromCartEvent.self)"
    
    let context: RemoveContext
    
    static func fireSectionWasRemoved(sectionIdx idx: Int, inCart cart: Cart) {
        fire(context: RemoveSectionContext(cart: cart, sectionIdx: idx))
    }
    
    static func fireUnitWasRemoved(ofProduct productIdx: Int, inSection sectionIdx: Int, inCart cart: Cart) {
        fire(context: RemoveUnitContext(cart: cart, sectionIdx: sectionIdx,
                                        productIdx: productIdx, allUnitsWasRemoved: false))
    }
    
    static func fireAllUnitsWasRemoved(ofProduct productIdx: Int, inSection sectionIdx: Int, inCart cart: Cart) {
        fire(context: RemoveUnitContext(cart: cart, sectionIdx: sectionIdx,
                                        productIdx: productIdx, allUnitsWasRemoved: true))
    }
    
    static func fire(context: RemoveContext) {
        EventBus.post(DidRemoveFromCartEvent.name,
                      sender: DidRemoveFromCartEvent(context: context))
    }
}

