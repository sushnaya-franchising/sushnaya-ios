//
// Created by Igor Kurylenko on 4/8/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation

class Price: Hashable {
    
    var value: CGFloat
    var modifierName: String?
    var currencyLocale: String
    
    var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: currencyLocale)
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value.asNSNumber)!
    }

    init(value: CGFloat, currencyLocale: String, modifierName: String? = nil) {
        self.value = value
        self.modifierName = modifierName
        self.currencyLocale = currencyLocale
    }

    var hashValue: Int {
        var result = 1
        result = 31 &* result &+ value.hashValue
        result = 31 &* result &+ (modifierName?.hashValue ?? 0)
        result = 31 &* result &+ currencyLocale.hashValue
        
        return result
    }
    
    static func zero(currencyLocale: String, modifierName: String?) -> Price {
        return Price(value: 0, currencyLocale: currencyLocale, modifierName: modifierName)
    }
}

func +(lhs: Price, rhs: Price) -> Price {
    assert(lhs.currencyLocale == rhs.currencyLocale && lhs.modifierName == rhs.modifierName)
    
    return Price(value: lhs.value + rhs.value, currencyLocale: lhs.currencyLocale, modifierName: lhs.modifierName)
}

func ==(lhs: Price, rhs: Price) -> Bool {
    if lhs === rhs {
        return true
    }
    
    return lhs.value == rhs.value &&
        lhs.modifierName == rhs.modifierName &&
        lhs.currencyLocale == rhs.currencyLocale
}
