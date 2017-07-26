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

    var locality: Locality? {
        return settings.locality
    }
    
    let settings = UserSettings()

    let cart = Cart()
    
    override init() {
        super.init()
        
        // todo: query the auth token
        authToken = "NTJiZTJmNjVhNTBjNDY3OTIwMjAyMTdjMjA4YTA0NGNhNzMxNjg3Zi0xNTAwMDM3OTE4MjA3LS0x"
        
        // todo: query locality
//        locality = ...
        
    }
}
