import Foundation
import AsyncDisplayKit
import CoreStore
import SwiftyJSON

class MenuCategoryEntity: NSManagedObject {
    @NSManaged var serverId: Int32
    @NSManaged var name: String
    @NSManaged var imageUrl: String?
    @NSManaged var imageWidth: NSNumber?
    @NSManaged var imageHeight: NSNumber?
    @NSManaged var rank: Float
    
    @NSManaged var menu: MenuEntity?
    @NSManaged var products: [ProductEntity]?
    
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
    
    var plainCategory: MenuCategory {
        return MenuCategory(serverId: serverId,
                            name: name,
                            imageUrl: imageUrl,
                            imageWidth: imageWidth,
                            imageHeight: imageHeight)
    }
}

extension MenuCategoryEntity: ImportableUniqueObject {
    typealias ImportSource = JSON
    typealias UniqueIDType = Int32
    
    class var uniqueIDKeyPath: String {
        return #keyPath(MenuCategoryEntity.serverId)
    }
    
    var uniqueIDValue: Int32 {
        get { return self.serverId }
        set { self.serverId = newValue }
    }
    
    class func uniqueID(from source: JSON, in transaction: BaseDataTransaction) throws -> Int32? {
        return source["id"].int32
    }
    
    func update(from source: ImportSource, in transaction: BaseDataTransaction) throws {
        let menuServerId = source["menuId"].int32!
        
        guard let menu = transaction.fetchOne(From<MenuEntity>(), Where("serverId", isEqualTo: menuServerId)) else {
            return
        }
        
        try! update(from: source, in: transaction, forMenu: menu)
    }
    
    func update(from source: ImportSource, in transaction: BaseDataTransaction, forMenu menu: MenuEntity) throws {
        self.menu = menu
        self.serverId = source["id"].int32!
        self.name = source["name"].string!
        self.rank = source["rank"].float!
        self.imageUrl = source["photo"]["url"].string!
        self.imageWidth = NSNumber(value: source["photo"]["width"].float!)
        self.imageHeight = NSNumber(value: source["photo"]["height"].float!)
    }
}
