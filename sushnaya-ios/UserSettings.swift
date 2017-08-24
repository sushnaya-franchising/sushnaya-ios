//
// Created by Igor Kurylenko on 4/25/17.
// Copyright (c) 2017 Igor Kurylenko. All rights reserved.
//

import Foundation
import SwiftEventBus

class UserSettings {
    var menu: Menu? {
        didSet {
            // todo: persist locality
        }
    }

    var isMenuSelected: Bool {
        get {
            return menu != nil
        }
    }
    
    private(set) var addresses = [Address]()
    
    init() {
        bindEventHandlers()
    }
    
    deinit {
        EventBus.unregister(self)
    }
    
    private func bindEventHandlers() {
        EventBus.onMainThread(self, name: DidSelectMenuEvent.name) { [unowned self] notification in
            guard let event = notification.object as? DidSelectMenuEvent else {
                return
            }
            
            self.menu = event.menu
        }
    }
    
    func addAddress(_ address: Address) {
        self.addresses.append(address)
    }
}
