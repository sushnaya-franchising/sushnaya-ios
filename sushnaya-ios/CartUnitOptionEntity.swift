import Foundation
import CoreStore
import SwiftyJSON

class CartUnitOptionEntity: NSManagedObject {
    @NSManaged var serverId: NSNumber?
    
    @NSManaged var productOption: ProductOptionEntity
    @NSManaged var price: ProductOptionPriceEntity
    
    @NSManaged var cartUnit: CartUnitEntity
    
    @NSManaged var addedAt: Int64
    
    @NSManaged var serverAddedAt: NSNumber?
    @NSManaged var updatedAt: NSNumber?
}
