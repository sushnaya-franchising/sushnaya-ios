import Foundation
import CoreData


class MenuEntity: NSManagedObject {
    @NSManaged var serverId: NSNumber    
    @NSManaged var locality: LocalityEntity
    
    @NSManaged var categories: [MenuCategoryEntity]?
}
