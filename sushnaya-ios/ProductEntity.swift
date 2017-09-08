import Foundation
import CoreData

class ProductEntity: NSManagedObject {
    @NSManaged var serverId: Int32
    @NSManaged var title: String
    @NSManaged var subtitle: String?
    @NSManaged var imageUrl: String?
    @NSManaged var imageWidth: NSNumber?
    @NSManaged var imageHeight: NSNumber?
    @NSManaged var isRecommended: Bool
    
    @NSManaged var pricing: [PriceEntity]
    @NSManaged var menuCategory: MenuCategoryEntity?

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
    
    var highestPrice: PriceEntity? {
        var result: PriceEntity?
        var highestValue: Double = 0
        
        pricing.forEach {
            if $0.value >= highestValue {
                highestValue = $0.value
                result = $0
            }
        }
        
        return result
    }
    
    var categoryTitle:String? {
        return menuCategory?.title
    }
    
    var plain: Product {
        return Product(serverId: serverId,
                       title: title,
                       subtitle: subtitle,
                       imageUrl: imageUrl,
                       imageWidth: imageWidth,
                       imageHeight: imageHeight,
                       pricing: plainPricing,
                       menuCategory: menuCategory?.plainCategory)
    }
    
    var plainPricing: [Price] {
        return pricing.map{ $0.plain }
    }
}
