//
//  DidAuthenticateEvent.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/24/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus

struct DidAuthenticateEvent: Event {
    static var name: String = "\(DidAuthenticateEvent.self)"
    
    var authToken: String
    
    static func fire(authToken: String) {
        EventBus.post(DidAuthenticateEvent.name, sender: DidAuthenticateEvent(authToken: authToken))
    }
}
