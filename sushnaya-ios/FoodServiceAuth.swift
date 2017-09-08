//
//  FoodServiceAuth.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 8/5/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import libPhoneNumber_iOS
import Alamofire
import PromiseKit

enum AuthenticationError: Error {
    case invalidPhoneNumber
    
    case invalidVerificationCode
}

class FoodServiceAuth {
    // todo: use ssl
    static let baseUrl = "http://localhost:8080/0.1.0"
    static let authenticateUrl = baseUrl + "/authenticate"
    static let tokenUrl = baseUrl + "/token"
    
    
    class func requestSMSWithVerificationCode(phoneNumber: String) {
        let parameters = ["phoneNumber": phoneNumber]
        
        Alamofire.request(authenticateUrl, method: .post, parameters: parameters).validate().response { response in
            if let error = response.error {
                DidNotRequestSMSWithVerificationCodeEvent.fire(error: error)
                
            } else {
                DidRequestSMSWithVerificationCodeEvent.fire(phoneNumber: phoneNumber)
            }
        }
    }
    
    class func requestAuthToken(phoneNumber: String, code: String) {
            let parameters = [
                "phoneNumber": phoneNumber,
                "code": code
            ]
            
            Alamofire.request(tokenUrl, method: .get, parameters: parameters).validate().responseString { response in
                if let error = response.error {
                    DidNotRequestAuthenticationTokenEvent.fire(error: error)
                
                } else {
                    DidRequestAuthenticationTokenEvent.fire(authToken: response.result.value!)
                }                
            }
    }
}

