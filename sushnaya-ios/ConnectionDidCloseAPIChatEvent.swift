//
//  ConnectionDidCloseAPIChatEvent.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/25/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus

struct ConnectionDidCloseAPIChatEvent: Event {
    static var name: String = "\(ConnectionDidCloseAPIChatEvent.self)"
    
    static func fire() {
        SwiftEventBus.post(ConnectionDidCloseAPIChatEvent.name)
    }
}
