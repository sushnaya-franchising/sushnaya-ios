//
//  Session.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/15/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus

class UserSession: NSObject {
    var authToken:String? {
        didSet {
            // todo: persist the auth token
        }
    }
    
    var isLoggedIn:Bool {
        get {
            return authToken != nil
        }
    }

    var menu: Menu? {
        get {
            return settings.menu
        }
        set {
            settings.menu = newValue
        }
    }
    
    let settings = UserSettings()

    let cart = Cart()
    
    override init() {
        super.init()
        
        // todo: get the auth token from datastorage
        // todo: get the menu locality from datastorage
        
        authToken = "YzUwNzM1YTU2MDgxYjU3Mjg3NGFmM2U5YzRmNWE3Mjk3NGJlNmY2NS0xNTAxOTI0ODExNjM1LTU4MDYzMDQ4NjgxODg2MzcyNzk"
        menu = FakeMenus[0]
        
    }
}
