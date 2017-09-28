import Foundation
import CoreStore

struct Product {
    var serverId: Int32
    var name: String
    var subheading: String?
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    var pricing: [Price]
    var menuCategory: MenuCategory?
    
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
    
    var highestPrice: Price? {
        var result: Price?
        var highestValue: Double = 0
        
        pricing.forEach {
            if $0.value >= highestValue {
                highestValue = $0.value
                result = $0
            }
        }
        
        return result
    }
    
    var categoryName:String? {
        return menuCategory?.name
    }        
}

extension Product: Hashable {
    var hashValue: Int {
        var result = 1
        result = 31 &* result &+ Int(serverId)
        result = 31 &* result &+ name.hashValue
        result = 31 &* result &+ (subheading?.hashValue ?? 0)
        result = 31 &* result &+ (imageUrl?.hashValue ?? 0)
        result = 31 &* result &+ (imageSize?.hashValue ?? 0)
        result = 31 &* result &+ HashValueUtil.hashValue(of: pricing)
        result = 31 &* result &+ (menuCategory?.hashValue ?? 0)
        
        return result
    }
}

func ==(lhs: Product, rhs: Product) -> Bool {
    return lhs.serverId == rhs.serverId &&
        lhs.name == rhs.name &&
        lhs.subheading == rhs.subheading &&
        lhs.imageSize == rhs.imageSize &&
        lhs.imageUrl == rhs.imageUrl &&
        lhs.pricing == rhs.pricing &&
        lhs.menuCategory == rhs.menuCategory
}
