import Foundation

struct CategoriesServerEvent: Event {
    static var name: String = "\(CategoriesServerEvent.self)"
    
    var categories: [CategoryDto]
    
    static func fire(categories: [CategoryDto]) {
        EventBus.post(CategoriesServerEvent.name, sender: CategoriesServerEvent(categories: categories))
    }
}
