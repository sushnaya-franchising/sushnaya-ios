//
//  API.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/22/17.
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

class Authentication {
    // todo: use ssl
    static let baseUrl = "http://auth.sushnaya.com:8443"
    static let authenticateUrl = baseUrl + "/authenticate"
    static let tokenUrl = baseUrl + "/token"


    class func requestSMSWithVerificationCode(phoneNumber: String) -> Promise<Void> {
        return Promise { fulfill, reject in
            let parameters = ["phoneNumber": phoneNumber.replacingOccurrences(of: "+", with: "")]

            //fulfill()

            Alamofire.request(authenticateUrl, method: .post, parameters: parameters).validate().response { response in
                if let error = response.error {
                    // todo: handle error gently
                    reject(error)

                } else {
                    fulfill()
                }
            }
        }
    }

    class func requestAuthToken(phoneNumber: String, code: String) -> Promise<String> {
        return Promise { fulfill, reject in
            let parameters = [
                    "phoneNumber": phoneNumber.replacingOccurrences(of: "+", with: ""),
                    "code": code
            ]

//            fulfill("token")

            Alamofire.request(tokenUrl, method: .get, parameters: parameters).validate().responseString { response in
                switch response.result {

                case .success:
                    fulfill(response.result.value!)

                case .failure(let error):
                    //todo: handle error gently
                    reject(error)
                }
            }
        }
    }
}
