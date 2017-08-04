//
//  ChangeLocalityEvent.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/25/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus

struct SelectMenuEvent: Event {
    static var name: String = "\(SelectMenuEvent.self)"
    
    var menus: [Menu]
    
    static func fire(menus: [Menu]) {
        EventBus.post(SelectMenuEvent.name, sender: SelectMenuEvent(menus: menus))
    }
}
