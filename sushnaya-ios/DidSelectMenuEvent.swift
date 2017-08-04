//
//  UpdateLocalityEvent.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/25/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus

struct DidSelectMenuEvent: Event {
    static var name: String = "\(DidSelectMenuEvent.self)"
    
    var menu: Menu
    
    static func fire(menu: Menu) {
        EventBus.post(DidSelectMenuEvent.name, sender: DidSelectMenuEvent(menu: menu))
    }
}
