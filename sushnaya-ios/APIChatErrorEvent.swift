//
//  APIChatConnectionError.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/25/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus

struct APIChatErrorEvent: Event {
    static var name: String = "\(APIChatErrorEvent.self)"
    
    var cause: Error
    
    static func fire(_ cause: Error) {
        EventBus.post(APIChatErrorEvent.name, sender: APIChatErrorEvent(cause: cause))
    }
}
