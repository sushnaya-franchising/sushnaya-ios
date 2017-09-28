import Foundation
import CoreStore
import SwiftyJSON

class CartUnitEntity: NSManagedObject {
    @NSManaged var serverId: NSNumber?
    
    @NSManaged var product: ProductEntity
    @NSManaged var price: ProductPriceEntity
    @NSManaged var options: [CartUnitOptionEntity]?
    
    @NSManaged var addedAt: Int64
    
    @NSManaged var serverAddedAt: NSNumber?
    @NSManaged var serverUpdatedAt: NSNumber?
}
