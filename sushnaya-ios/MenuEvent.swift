import Foundation
import SwiftyJSON

struct GetMenuEvent: Event {
    static var name: String = "\(GetMenuEvent.self)"
    
    static func fire() {
        EventBus.post(GetMenuEvent.name)
    }
}

struct SelectMenuServerEvent: Event {
    static var name: String = "\(SelectMenuServerEvent.self)"
    
    var menus: [MenuDto]
    
    static func fire(menus: [MenuDto]) {
        EventBus.post(SelectMenuServerEvent.name, sender: SelectMenuServerEvent(menus: menus))
    }
}

struct DidSelectMenuServerEvent: Event {
    static var name: String = "\(DidSelectMenuServerEvent.self)"
    
    var menuDto: MenuDto
    
    static func fire(menuDto: MenuDto) {
        EventBus.post(DidSelectMenuServerEvent.name, sender: DidSelectMenuServerEvent(menuDto: menuDto))
    }
}


struct DidSelectMenuEvent: Event {
    static var name: String = "\(DidSelectMenuEvent.self)"
    
    var menuDto: MenuDto
    
    static func fire(menuDto: MenuDto) {
        EventBus.post(DidSelectMenuEvent.name, sender: DidSelectMenuEvent(menuDto: menuDto))
    }
}

struct DidRequestMenusEvent: Event {
    static var name: String = "\(DidRequestMenusEvent.self)"
    
    var menusJSON: JSON
    
    static func fire(menusJSON: JSON) {
        EventBus.post(DidRequestMenusEvent.name, sender: DidRequestMenusEvent(menusJSON: menusJSON))
    }
}

