//
//  TermsOfUseUpdatedEvent.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/24/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus

struct DidUpdateTermsOfUseServerEvent: Event {
    static var name: String = "\(DidUpdateTermsOfUseServerEvent.self)"
    
    var url: String
    
    static func fire(url: String) {
        EventBus.post(DidUpdateTermsOfUseServerEvent.name, sender: DidUpdateTermsOfUseServerEvent(url: url))
    }
}
