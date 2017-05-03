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
        return userSettings.locality
    }
    
    let userSettings = UserSettings()

    let cart = Cart()
    
    override init() {
        super.init()
        
        // todo: query the auth token
        authToken = "Mi1SNkF6UDJjRkVaWFA1Mkl6TlRMOE85VStodz09"
        
        // todo: query locality
//        locality = ...
        
    }
}
