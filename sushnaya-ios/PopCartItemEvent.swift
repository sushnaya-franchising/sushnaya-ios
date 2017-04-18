//
//  PopCartItem.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/18/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

struct PopCartItemEvent: Event {
    static var name: String = "\(PopCartItemEvent.self)"
    
    static func fire() {
        EventBus.post(PopCartItemEvent.name)        
    }
}
