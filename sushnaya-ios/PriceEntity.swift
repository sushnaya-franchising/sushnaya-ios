import Foundation
import CoreStore
import SwiftyJSON

class PriceEntity: NSManagedObject {
    @NSManaged var serverId: Int32
    @NSManaged var value: Double
    @NSManaged var modifierName: String?
    @NSManaged var currencyLocale: String
    
    @NSManaged var addedAt: Int64
    @NSManaged var updatedAt: Int64
    
    var plain: Price {
        return Price(value: value,
                     currencyLocale: currencyLocale,
                     modifierName: modifierName,
                     serverId: serverId)
    }
    
    var formattedValue: String {
        return PriceEntity.formattedPrice(value: value, currencyLocale: currencyLocale)
    }
    
    public static func formattedPrice(value: Double, currencyLocale: String) -> String {
        guard value > 0 else { return "бесплатно" }
        
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: currencyLocale)
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value))!
    }
}

class ProductPriceEntity: PriceEntity {
    @NSManaged var product: ProductEntity?
}

class ProductOptionPriceEntity: PriceEntity {
    @NSManaged var productOption: ProductOptionEntity?
}

extension ProductPriceEntity: ImportableUniqueObject {
    typealias ImportSource = JSON
    typealias UniqueIDType = Int32
    
    class var uniqueIDKeyPath: String {
        return #keyPath(PriceEntity.serverId)
    }
    
    var uniqueIDValue: Int32 {
        get { return self.serverId }
        set { self.serverId = newValue }
    }
    
    class func uniqueID(from source: JSON, in transaction: BaseDataTransaction) throws -> Int32? {
        return source["id"].int32
    }
    
    func update(from source: JSON, in transaction: BaseDataTransaction) throws {
        let productServerId = source["productId"].int32!
        
        guard let product = transaction.fetchOne(From<ProductEntity>(), Where("serverId", isEqualTo: productServerId)) else {
            return
        }
        
        try! update(from: source, in: transaction, forProduct: product)
    }
    
    func update(from source: JSON, in transaction: BaseDataTransaction, forProduct product: ProductEntity) throws {
        self.serverId = source["id"].int32!
        self.addedAt = source["addedAt"].int64!
        self.updatedAt = source["updatedAt"].int64!
        self.value = source["value"].double!
        self.currencyLocale = source["currencyLocale"].string!
        self.modifierName = source["modifierName"].string
        self.product = product
    }
}

extension ProductOptionPriceEntity: ImportableUniqueObject {
    typealias ImportSource = JSON
    typealias UniqueIDType = Int32
    
    class var uniqueIDKeyPath: String {
        return #keyPath(PriceEntity.serverId)
    }
    
    var uniqueIDValue: Int32 {
        get { return self.serverId }
        set { self.serverId = newValue }
    }
    
    class func uniqueID(from source: JSON, in transaction: BaseDataTransaction) throws -> Int32? {
        return source["id"].int32
    }
    
    func update(from source: JSON, in transaction: BaseDataTransaction) throws {
        let optionServerId = source["optionId"].int32!
        
        guard let option = transaction.fetchOne(From<ProductOptionEntity>(), Where("serverId", isEqualTo: optionServerId)) else {
            return
        }
        
        try! update(from: source, in: transaction, forProductOption: option)
    }
    
    func update(from source: JSON, in transaction: BaseDataTransaction, forProductOption option: ProductOptionEntity) throws {
        self.serverId = source["id"].int32!
        self.addedAt = source["addedAt"].int64!
        self.updatedAt = source["updatedAt"].int64!
        self.value = source["value"].double!
        self.currencyLocale = source["currencyLocale"].string!
        self.modifierName = source["modifierName"].string
        self.productOption = option
    }
}

