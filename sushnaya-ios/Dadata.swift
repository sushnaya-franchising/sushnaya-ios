//
//  Dadata.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 5/6/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

class Dadata {
    fileprivate typealias Json = [String: Any]
    
    fileprivate static var pendingRequests = [DataRequest]()
    
    static func requestAddressSuggestions(query: String, cityFiasId: String, fromBound: String = "street") -> Promise<[String]?> {
        return Promise { fulfill, reject in
            let addressSuggestionsUrl = "https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/address"
            
            let parameters:[String: Any] = [
                "query":  query,
                "count": 11,
                "locations": [
                    ["city_fias_id": cityFiasId]
                ],
                "restrict_value": true,
                "from_bound": [ "value": fromBound ],
                "to_bound": [ "value": "house" ]
            ]
            
            let headers:[String: String] = [
                "Authorization": "Token 5990fe6685c7b4c9e6a76dc6f37d92e880f5c534",
                "Accept": "application/json",
                "Content-Type": "application/json"
            ]
            
            Alamofire.request(addressSuggestionsUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                
                if let error = response.error {
                    reject(error)
                    return
                }
                
                guard let json = response.result.value as? Json else {
                    fulfill(nil)
                    return
                }
                
                guard let suggestions = parseSuggestions(json: json) else {
                    fulfill(nil)
                    return
                }
                
                fulfill(suggestions)
            }
        }
    }
    
    private static func parseSuggestions(json: Json) -> [String]? {
        guard let suggestionsJsonArray = json["suggestions"] as? [Json] else {
            return nil
        }
        
        var result = [String]()
        
        for suggestionJson in suggestionsJsonArray {
            if let suggestion = suggestionJson["value"] as? String {
                result.append(suggestion)
            }
        }
        
        return result
    }
    
    // todo: use Dadata custom session manager
    static func cancelAllRequests() -> Promise<()> {
        return Promise { fulfill, reject in
            Alamofire.SessionManager.default.session.getAllTasks { tasks in
                tasks.forEach {
                    $0.cancel()
                }
                fulfill()
            }
        }
    }
}
