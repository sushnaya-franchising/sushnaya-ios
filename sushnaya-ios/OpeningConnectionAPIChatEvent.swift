//
//  StartingAPIChatConnectionEvent.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/25/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus

struct OpeningConnectionAPIChatEvent: Event {
    static var name: String = "\(OpeningConnectionAPIChatEvent.self)"
    
    static func fire() {
        EventBus.post(OpeningConnectionAPIChatEvent.name)
    }
}
