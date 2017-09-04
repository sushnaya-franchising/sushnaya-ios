import Foundation
import CoreData

class ProductEntity: NSManagedObject {
    @NSManaged var serverId: Int
    @NSManaged var title: String
    @NSManaged var subtitle: String?
    @NSManaged var imageUrl: String?
    @NSManaged var imageWidth: NSNumber?
    @NSManaged var imageHeight: NSNumber?
    
    @NSManaged var pricing: [PriceEntity]
    @NSManaged var category: MenuCategoryEntity

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
    
    var categoryTitle:String {
        return category.title
    }                
}
