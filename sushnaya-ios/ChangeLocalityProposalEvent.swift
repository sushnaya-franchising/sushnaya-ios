//
//  ChangeLocalityEvent.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/25/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus

struct ChangeLocalityProposalEvent {
    static var name: String = "\(ChangeLocalityProposalEvent.self)"
    
    var localities: [Locality]
    
    static func fire(localities: [Locality]) {
        SwiftEventBus.post(ChangeLocalityProposalEvent.name, sender: ChangeLocalityProposalEvent(localities: localities))
    }
}
