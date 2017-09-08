import Foundation

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
        EventBus.post(DidSelectCategoryEvent.name, sender: DidSelectCategoryEvent(category: category))
    }
}
