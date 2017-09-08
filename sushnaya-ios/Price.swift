import Foundation
import CoreStore

struct Price {
    var value: Double
    var currencyLocale: String
    var modifierName: String?
    var serverId: Int32
    
    init(value: Double, currencyLocale: String, modifierName: String?) {
        self.init(value: value, currencyLocale: currencyLocale, modifierName: modifierName, serverId: -1)
    }
    
    init(value: Double, currencyLocale: String, modifierName: String?, serverId: Int32) {
        self.value = value
        self.currencyLocale = currencyLocale
        self.modifierName = modifierName
        self.serverId = serverId
    }
    
    var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: currencyLocale)
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: self.value))!
    }    
}

extension Price: Hashable {
    var hashValue: Int {
        var result = 1
        result = 31 &* result &+ value.hashValue
        result = 31 &* result &+ (modifierName?.hashValue ?? 0)
        result = 31 &* result &+ currencyLocale.hashValue
        
        return result
    }
}

func +(lhs: Price, rhs: Price) -> Price {
    assert(lhs.currencyLocale == rhs.currencyLocale && lhs.modifierName == rhs.modifierName)
    
    return Price(value: lhs.value + rhs.value, currencyLocale: lhs.currencyLocale, modifierName: lhs.modifierName)
}


func ==(lhs: Price, rhs: Price) -> Bool {
    return lhs.value == rhs.value &&
        lhs.modifierName == rhs.modifierName &&
        lhs.currencyLocale == rhs.currencyLocale
}
