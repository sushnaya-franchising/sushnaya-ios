//
//  UpdateLocalityEvent.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/25/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus

struct ChangeLocalityEvent {
    static var name: String = "\(ChangeLocalityEvent.self)"
    
    var locality: Locality
    
    static func fire(locality: Locality) {
        EventBus.post(ChangeLocalityEvent.name, sender: ChangeLocalityEvent(locality: locality))
    }
}
