import Foundation
import SwiftyJSON

struct CategoriesServerEvent: Event {
    static var name: String = "\(CategoriesServerEvent.self)"
    
    var categories: [CategoryDto]
    
    static func fire(categories: [CategoryDto]) {
        EventBus.post(CategoriesServerEvent.name, sender: CategoriesServerEvent(categories: categories))
    }
}

struct DidSelectCategoryEvent: Event {
    static var name: String = "\(DidSelectCategoryEvent.self)"
    
    var category: MenuCategoryEntity?
    
    static func fire(category: MenuCategoryEntity?) {
        guard let category = category else {
            return DidSelectRecommendationsEvent.fire()
        }
        
        EventBus.post(DidSelectCategoryEvent.name, sender: DidSelectCategoryEvent(category: category))
    }
}

struct DidSelectRecommendationsEvent: Event {
    static var name: String = "\(DidSelectRecommendationsEvent.self)"
    
    static func fire() {
        EventBus.post(DidSelectRecommendationsEvent.name, sender: DidSelectRecommendationsEvent())
    }
}

struct SyncCategoriesEvent: Event {
    static var name: String = "\(SyncCategoriesEvent.self)"
    
    var categoriesJSON: JSON
    var menuId: Int32
    
    static func fire(categoriesJSON: JSON, menuId: Int32) {
        EventBus.post(SyncCategoriesEvent.name, sender: SyncCategoriesEvent(categoriesJSON: categoriesJSON, menuId: menuId))
    }
}

