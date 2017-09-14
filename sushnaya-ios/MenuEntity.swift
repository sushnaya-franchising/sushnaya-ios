import Foundation
import CoreStore
import SwiftyJSON


class MenuEntity: NSManagedObject {
    @NSManaged var serverId: Int32
    @NSManaged var locality: LocalityEntity
    
    @NSManaged var categories: [MenuCategoryEntity]?
}

extension MenuEntity: ImportableUniqueObject {
    typealias ImportSource = JSON
    typealias UniqueIDType = Int32
    
    class var uniqueIDKeyPath: String {
        return #keyPath(MenuEntity.serverId)
    }
    
    var uniqueIDValue: Int32 {
        get { return self.serverId }
        set { self.serverId = newValue }
    }
    
    class func uniqueID(from source: JSON, in transaction: BaseDataTransaction) throws -> Int32? {
        return source["id"].int32!
    }
    
    func update(from source: JSON, in transaction: BaseDataTransaction) throws {
        self.serverId = source["id"].int32!
        
        self.locality = transaction.edit(self.locality) ??
            transaction.create(Into<LocalityEntity>())
        
        try! self.locality.update(from: source["locality"], in: transaction)
        
        if (source["isSelected"].bool ?? false) == true {
            let userSettings = transaction.fetchOne(From<UserSettingsEntity>())!
            userSettings.selectedMenu = self
        }
        
        if let categoriesJSON = source["categories"].array {
            try! updateCategories(from: categoriesJSON, in: transaction)
        }
        
        if let recommendationsJSON = source["recommendations"].array {
            try! updateRecommendedProducts(from: recommendationsJSON, in: transaction)
        }
    }
    
    private func updateCategories(from source: [JSON], in transaction: BaseDataTransaction) throws {
        try! deleteDeprecatedCategories(update: source, in: transaction)
        
        for categorySource in source {
            try! updateCategory(from: categorySource, in: transaction)
        }
    }
    
    private func deleteDeprecatedCategories(update: [JSON], in transaction: BaseDataTransaction) throws {
        let currentCategories = transaction.fetchAll(
            From<MenuCategoryEntity>(),
            Where("menu.serverId", isEqualTo: self.serverId),
            OrderBy(.ascending(#keyPath(MenuCategoryEntity.serverId)))) ?? [MenuCategoryEntity]()
        
        for currentCategory in currentCategories {
            if update.filter({$0["id"].int32! == currentCategory.serverId}).first == nil {
                transaction.delete(currentCategory)
            }
        }
    }
    
    private func updateCategory(from source: JSON, in transaction: BaseDataTransaction) throws {
        let categoryServerId = source["id"].int32!
        let category = transaction.fetchOne(From<MenuCategoryEntity>(), Where("serverId", isEqualTo: categoryServerId)) ??
            transaction.create(Into<MenuCategoryEntity>())
        
        try! category.update(from: source, in: transaction, forMenu: self)
    }
    
    private func updateRecommendedProducts(from source: [JSON], in transaction: BaseDataTransaction) throws {
        try! resetDeprecatedRecommendations(update: source, in: transaction)
        
        for productSource in source {
            try! updateRecommendedProduct(from: productSource, in: transaction)
        }
    }
    
    private func resetDeprecatedRecommendations(update: [JSON], in transaction: BaseDataTransaction) throws {
        let currentRecommendedProducts = transaction.fetchAll(
            From<ProductEntity>(),
            Where("category.menu.serverId", isEqualTo: self.serverId) &&
            Where("isRecommended", isEqualTo: true),
            OrderBy(.ascending(#keyPath(ProductEntity.name)))) ?? [ProductEntity]()
        
        for currentRecommendedProduct in currentRecommendedProducts {
            if update.filter({$0["id"].int32! == currentRecommendedProduct.serverId}).first == nil {
                currentRecommendedProduct.isRecommended = false
            }
        }
    }
    
    private func updateRecommendedProduct(from source: JSON, in transaction: BaseDataTransaction) throws {
        let productServerId = source["id"].int32!
        let product = transaction.fetchOne(From<ProductEntity>(), Where("serverId", isEqualTo: productServerId)) ??
            transaction.create(Into<ProductEntity>())
        
        product.isRecommended = true        
        
        try! product.update(from: source, in: transaction)
    }
}

