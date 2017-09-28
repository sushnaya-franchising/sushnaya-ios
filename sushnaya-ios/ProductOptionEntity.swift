import Foundation
import CoreStore
import SwiftyJSON

class ProductOptionEntity: NSManagedObject {
    @NSManaged var serverId: Int32
    @NSManaged var name: String
    @NSManaged var rank: Float
    
    @NSManaged var addedAt: Int64
    @NSManaged var updatedAt: Int64
    
    @NSManaged var pricing: [ProductOptionPriceEntity]
    @NSManaged var product: ProductEntity
}

extension ProductOptionEntity: ImportableUniqueObject {
    typealias ImportSource = JSON
    typealias UniqueIDType = Int32
    
    class var uniqueIDKeyPath: String {
        return #keyPath(ProductOptionEntity.serverId)
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
        self.name = source["name"].string!        
        self.rank = source["rank"].float!
        
        try! updatePricing(from: source["pricing"].array!, in: transaction)        
        
        self.product = product
    }
    
    func updatePricing(from source: [JSON], in transaction: BaseDataTransaction) throws {
        try! deleteDeprecatedPrices(update: source, in: transaction)
        
        for priceJSON in source {
            try! updatePrice(from: priceJSON, in: transaction)
        }
    }
    
    private func deleteDeprecatedPrices(update: [JSON], in transaction: BaseDataTransaction) throws {
        guard let currentPricing = transaction.fetchAll(
            From<ProductOptionPriceEntity>(),
            Where("productOption.serverId", isEqualTo: self.serverId),
            OrderBy(.ascending(#keyPath(PriceEntity.serverId)))) else { return }
        
        for currentPrice in currentPricing {
            if update.filter({$0["id"].int32! == currentPrice.serverId}).first == nil {
                transaction.delete(currentPrice)
            }
        }
    }
    
    func updatePrice(from source: JSON, in transaction: BaseDataTransaction) throws {
        let priceServerId = source["id"].int32!
        let price = transaction.fetchOne(From<ProductOptionPriceEntity>(), Where("serverId", isEqualTo: priceServerId)) ??
            transaction.create(Into<ProductOptionPriceEntity>())
        
        try! price.update(from: source, in: transaction, forProductOption: self)
    }
}
