import Foundation
import CoreStore
import SwiftyJSON

class ProductOptionEntity: NSManagedObject {
    @NSManaged var serverId: Int32
    
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
        self.product = product
    }
}
