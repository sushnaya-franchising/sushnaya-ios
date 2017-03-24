//
//  AuthenticationEvent.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/24/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus

struct AuthenticationEvent: Event {
    
    static var name: String = "\(AuthenticationEvent.self)"
    
    var authToken: String
    
    static func fire(authToken: String) {
        SwiftEventBus.post(AuthenticationEvent.name, sender: AuthenticationEvent(authToken: authToken))
    }
}
