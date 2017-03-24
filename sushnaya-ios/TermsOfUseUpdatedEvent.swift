//
//  TermsOfUseUpdatedEvent.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/24/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus

struct TermsOfUseUpdatedEvent: Event {
    
    static var name: String = "\(TermsOfUseUpdatedEvent.self)"
    
    var url: String
    
    static func fire(url: String) {
        SwiftEventBus.post(TermsOfUseUpdatedEvent.name, sender: TermsOfUseUpdatedEvent(url: url))
    }
}
