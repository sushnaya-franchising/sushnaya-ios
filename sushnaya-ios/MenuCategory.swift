import Foundation

struct MenuCategory {
    var serverId: Int32
    var name: String
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
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

extension MenuCategory: Hashable {
    var hashValue: Int {
        var result = 1
        result = 31 &* result &+ Int(serverId)
        result = 31 &* result &+ name.hashValue
        result = 31 &* result &+ (imageUrl?.hashValue ?? 0)
        result = 31 &* result &+ (imageSize?.hashValue ?? 0)
        
        return result
    }
}

func ==(lhs: MenuCategory, rhs: MenuCategory) -> Bool {
    return lhs.serverId == rhs.serverId &&
        lhs.name == rhs.name &&
        lhs.imageSize == rhs.imageSize &&
        lhs.imageUrl == rhs.imageUrl
}
