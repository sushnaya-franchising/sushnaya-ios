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
