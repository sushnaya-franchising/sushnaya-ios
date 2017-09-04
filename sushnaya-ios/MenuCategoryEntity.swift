import Foundation
import AsyncDisplayKit
import CoreData

class MenuCategoryEntity: NSManagedObject {
    @NSManaged var serverId: Int
    @NSManaged var title: String    
    @NSManaged var imageUrl: String?
    @NSManaged var imageWidth: NSNumber?
    @NSManaged var imageHeight: NSNumber?
    
    @NSManaged var menu: MenuEntity
    @NSManaged var products: [ProductEntity]
    
    var imageSize: CGSize? {
        get {
            guard let width = imageWidth?.floatValue,
                let height = imageHeight?.floatValue else { return nil }
            
            return CGSize(width: CGFloat(width), height: CGFloat(height))
        }
        
        set {
            guard let value = newValue else { return }
            
            self.imageWidth = NSNumber(value: Float(value.width))
            self.imageHeight = NSNumber(value: Float(value.height))
        }
    }
}
