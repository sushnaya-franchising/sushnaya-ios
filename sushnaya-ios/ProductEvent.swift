import Foundation
import SwiftyJSON

struct RecommendationsServerEvent: Event {
    static var name: String = "\(RecommendationsServerEvent.self)"
    
    var products: [ProductDto]
    
    static func fire(products: [ProductDto]) {
        EventBus.post(RecommendationsServerEvent.name, sender: RecommendationsServerEvent(products: products))
    }
}

struct SyncProductsEvent: Event {
    static var name: String = "\(SyncProductsEvent.self)"
    
    var productsJSON: JSON
    var categoryId: Int32
    
    static func fire(productsJSON: JSON, categoryId: Int32) {
        EventBus.post(SyncProductsEvent.name, sender:
            SyncProductsEvent(productsJSON: productsJSON, categoryId: categoryId))
    }
}
