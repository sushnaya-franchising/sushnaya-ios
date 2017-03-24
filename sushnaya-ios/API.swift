//
//  API.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/22/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import PromiseKit
import libPhoneNumber_iOS

enum APIError: Error {
    case invalidPhoneNumber
    
    case invalidVerificationCode        
}

class API {
    static let baseUrl = "https://sushnaya.com/0.1.0/"
//    static let webSocketUrl = "wss://sushnaya.com:8080/0.1.0/"
    static let webSocketUrl = "wss://echo.websocket.org"
    
    class func requestSMSWithVerificationCode(phoneNumber: String) -> Promise<Void> {
        return Promise { fulfill, reject in
            // todo: post to server phoneNumberUtil.format(phoneNumber, numberFormat: .E164)
            
            Debouncer(delay: 1, callback: fulfill).apply() // simulate network delay
        }
    }
    
    class func requestAuthToken(code: String) -> Promise<String> {
        return Promise { fullfill, reject in
            // todo: request auth token
            
    
            Debouncer(delay: 1) {
                guard code.characters.count == 5 else {
                    reject(APIError.invalidVerificationCode)
                    return
                }
                
                fullfill("Mi1SNkF6UDJjRkVaWFA1Mkl6TlRMOE85VStodz09")// todo: encode an accepted user agreement hash in the auth token
            }.apply() // simulate network delay
            
        }
    }
    
    class func openAPIChat(authToken: String) -> Promise<APIChat> {
        return APIChat.connect(authToken: authToken, webSocketUrl: webSocketUrl)
    }
}
