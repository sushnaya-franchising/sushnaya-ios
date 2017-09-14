import Foundation
import CoreStore
import SwiftyJSON

class ProductEntity: NSManagedObject {
    @NSManaged var serverId: Int32
    @NSManaged var name: String
    @NSManaged var subheading: String?
    @NSManaged var imageUrl: String?
    @NSManaged var imageWidth: NSNumber?
    @NSManaged var imageHeight: NSNumber?
    @NSManaged var isRecommended: Bool
    @NSManaged var rank: Float
    
    @NSManaged var options: [ProductOptionEntity]?
    @NSManaged var pricing: [PriceEntity]
    @NSManaged var category: MenuCategoryEntity?

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
    
    var categoryName:String? {
        return category?.name
    }
    
    var plain: Product {
        return Product(serverId: serverId,
                       name: name,
                       subheading: subheading,
                       imageUrl: imageUrl,
                       imageWidth: imageWidth,
                       imageHeight: imageHeight,
                       pricing: plainPricing,
                       menuCategory: category?.plainCategory)
    }
    
    var plainPricing: [Price] {
        return pricing.map{ $0.plain }
    }
}

extension ProductEntity: ImportableUniqueObject {
    typealias ImportSource = JSON
    typealias UniqueIDType = Int32
    
    class var uniqueIDKeyPath: String {
        return #keyPath(ProductEntity.serverId)
    }
    
    var uniqueIDValue: Int32 {
        get { return self.serverId }
        set { self.serverId = newValue }
    }
    
    class func uniqueID(from source: JSON, in transaction: BaseDataTransaction) throws -> Int32? {
        return source["id"].int32
    }
    
    func update(from source: JSON, in transaction: BaseDataTransaction) throws {
        let categoryServerId = source["categoryId"].int32!
        
        guard let category = transaction.fetchOne(From<MenuCategoryEntity>(), Where("serverId", isEqualTo: categoryServerId)) else {
            return
        }
        
        try! update(from: source, in: transaction, forCategory: category)
    }
    
    func update(from source: JSON, in transaction: BaseDataTransaction, forCategory category: MenuCategoryEntity) throws {
        self.category = category
        self.serverId = source["id"].int32!
        self.name = source["name"].string!
        self.subheading = source["subheading"].string!
        self.rank = source["rank"].float!
        self.imageUrl = source["photo"]["url"].string!
        self.imageWidth = NSNumber(value: source["photo"]["width"].float!)
        self.imageHeight = NSNumber(value: source["photo"]["height"].float!)
        
        try! updatePricing(from: source["pricing"].array!, in: transaction)
        
        if let optionsJSON = source["options"].array {
            try! updateOptions(from: optionsJSON, in: transaction)
        }
    }
    
    func updatePricing(from source: [JSON], in transaction: BaseDataTransaction) throws {
        try! deleteDeprecatedPrices(update: source, in: transaction)
        
        for priceJSON in source {
            try! updatePrice(from: priceJSON, in: transaction)
        }
    }
    
    private func deleteDeprecatedPrices(update: [JSON], in transaction: BaseDataTransaction) throws {
        let currentPricing = transaction.fetchAll(
            From<PriceEntity>(),
            Where("product.serverId", isEqualTo: self.serverId),
            OrderBy(.ascending(#keyPath(PriceEntity.serverId)))) ?? [PriceEntity]()
        
        for currentPrice in currentPricing {
            if update.filter({$0["id"].int32! == currentPrice.serverId}).first == nil {
                transaction.delete(currentPrice)
            }
        }
    }
    
    func updateOptions(from source: [JSON], in transaction: BaseDataTransaction) throws {
        try! deleteDeprecatedOptions(update: source, in: transaction)
        
        for optionJSON in source {
            try! updateOption(from: optionJSON, in: transaction)
        }
    }
    
    private func deleteDeprecatedOptions(update: [JSON], in transaction: BaseDataTransaction) throws {
        let currentOptions = transaction.fetchAll(
            From<ProductOptionEntity>(),
            Where("product.serverId", isEqualTo: self.serverId),
            OrderBy(.ascending(#keyPath(ProductOptionEntity.serverId)))) ?? [ProductOptionEntity]()
        
        for currentOption in currentOptions {
            if update.filter({$0["id"].int32! == currentOption.serverId}).first == nil {
                transaction.delete(currentOption)
            }
        }
    }
    
    func updatePrice(from source: JSON, in transaction: BaseDataTransaction) throws {
        let priceServerId = source["id"].int32!
        let price = transaction.fetchOne(From<PriceEntity>(), Where("serverId", isEqualTo: priceServerId)) ??
            transaction.create(Into<PriceEntity>())
        
        try! price.update(from: source, in: transaction, forProduct: self)
    }
    
    func updateOption(from source: JSON, in transaction: BaseDataTransaction) throws {
        let optionServerId = source["id"].int32!
        let option = transaction.fetchOne(From<ProductOptionEntity>(), Where("serverId", isEqualTo: optionServerId)) ??
            transaction.create(Into<ProductOptionEntity>())
        
        try! option.update(from: source, in: transaction, forProduct: self)
    }
}
