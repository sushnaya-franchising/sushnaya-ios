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
    
    var menuJSON: JSON
    
    static func fire(menuJSON: JSON) {
        EventBus.post(DidSelectMenuEvent.name, sender: DidSelectMenuEvent(menuJSON: menuJSON))
    }
}

struct SyncMenusEvent: Event {
    static var name: String = "\(SyncMenusEvent.self)"
    
    var menusJSON: JSON
    
    static func fire(menusJSON: JSON) {
        EventBus.post(SyncMenusEvent.name, sender: SyncMenusEvent(menusJSON: menusJSON))
    }
}

struct DidSyncMenusEvent: Event {
    static var name: String = "\(DidSyncMenusEvent.self)"
    
    static func fire() {
        EventBus.post(DidSyncMenusEvent.name, sender: DidSyncMenusEvent())
    }
}


