//
// Created by Igor Kurylenko on 4/25/17.
// Copyright (c) 2017 Igor Kurylenko. All rights reserved.
//

import Foundation
import SwiftEventBus

class UserSettings {
    var locality: Locality? {
        didSet {
            // todo: persist locality
        }
    }

    var isLocalitySelected: Bool {
        get {
            return locality != nil
        }
    }
    
    var addresses: [Address]?
    
    init() {
        bindEventHandlers()
    }
    
    deinit {
        EventBus.unregister(self)
    }
    
    private func bindEventHandlers() {
        EventBus.onMainThread(self, name: ChangeLocalityEvent.name) { [unowned self] notification in
            guard let event = notification.object as? ChangeLocalityEvent else {
                return
            }
            
            self.locality = event.locality
        }
    }
}
