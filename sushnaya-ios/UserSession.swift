//
//  Session.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/15/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

class UserSession {
    var isLoggedIn = false
    
    private init(){}
    
    class func sharedInstance() -> UserSession {
        struct Singleton {
            static var sharedInstance = UserSession()
        }
        
        return Singleton.sharedInstance
    }
}
