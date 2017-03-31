//
//  ConnectionDidOpenAPIChatEvent.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/25/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus

struct ConnectionDidOpenAPIChatEvent: Event {
    static var name: String = "\(ConnectionDidOpenAPIChatEvent.self)"
    
    static func fire() {
        EventBus.post(ConnectionDidOpenAPIChatEvent.name)
    }
}
