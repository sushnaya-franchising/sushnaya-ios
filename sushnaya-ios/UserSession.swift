//
//  Session.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/15/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

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
    
    // todo: create UserSettings and move this property there
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
    
    override init() {
        super.init()
        
        // todo: query the auth token
        authToken = "Mi1SNkF6UDJjRkVaWFA1Mkl6TlRMOE85VStodz09"
        
        // todo: query locality
//        locality = ...
    }
}
