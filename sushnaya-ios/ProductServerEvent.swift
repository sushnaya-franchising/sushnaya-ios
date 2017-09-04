import Foundation

struct RecommendationsServerEvent: Event {
    static var name: String = "\(RecommendationsServerEvent.self)"
    
    var products: [ProductDto]
    
    static func fire(products: [ProductDto]) {
        EventBus.post(RecommendationsServerEvent.name, sender: RecommendationsServerEvent(products: products))
    }
}

