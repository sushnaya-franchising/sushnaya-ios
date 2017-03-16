//
//  Session.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/15/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import DigitsKit

class UserSession {
    var isLoggedIn:Bool {
        get {
            return Digits.sharedInstance().session()?.userID != nil
        }
    }
    
    private init(){}
    
    class func sharedInstance() -> UserSession {
        struct Singleton {
            static var sharedInstance = UserSession()
        }
        
        return Singleton.sharedInstance
    }
}
