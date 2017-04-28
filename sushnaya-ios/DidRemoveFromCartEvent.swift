//
//  DidRemoveFromCart.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/11/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

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

