import Foundation
import CoreData

class PriceEntity: NSManagedObject {
    @NSManaged var serverId: Int32
    @NSManaged var value: Double
    @NSManaged var modifierName: String?
    @NSManaged var currencyLocale: String
    
    @NSManaged var product: ProductEntity
    
    var plain: Price {
        return Price(value: value,
                     currencyLocale: currencyLocale,
                     modifierName: modifierName,
                     serverId: serverId)
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
