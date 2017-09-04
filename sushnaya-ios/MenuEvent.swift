//
//  GetMenuEvent.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/25/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus

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

struct DidSelectMenuEvent: Event {
    static var name: String = "\(DidSelectMenuEvent.self)"
    
    var menuDto: MenuDto
    
    static func fire(menuDto: MenuDto) {
        EventBus.post(DidSelectMenuEvent.name, sender: DidSelectMenuEvent(menuDto: menuDto))
    }
}
