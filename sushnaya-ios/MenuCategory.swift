import Foundation

struct MenuCategory {
    var serverId: Int
    var title: String
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
        result = 31 &* result &+ serverId
        result = 31 &* result &+ title.hashValue        
        result = 31 &* result &+ (imageUrl?.hashValue ?? 0)
        result = 31 &* result &+ (imageSize?.hashValue ?? 0)
        
        return result
    }
}

func ==(lhs: MenuCategory, rhs: MenuCategory) -> Bool {
    return lhs.serverId == rhs.serverId &&
        lhs.title == rhs.title &&
        lhs.imageSize == rhs.imageSize &&
        lhs.imageUrl == rhs.imageUrl
}
