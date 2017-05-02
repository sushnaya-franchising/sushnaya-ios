 //
//  YandexGeocoder.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/29/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

class YandexGeocoder {
    fileprivate typealias Json = [String: Any]
    
    static func requestAddress(coordinate: CLLocationCoordinate2D) -> Promise<Address?> {
        let parameters: Parameters = [
            "kind": "house",
            "results": 1,
            "format": "json",
            "geocode": "\(coordinate.longitude),\(coordinate.latitude)"
        ]
        
        return Promise { fulfill, reject in
            Alamofire.request("https://geocode-maps.yandex.ru/1.x/", parameters: parameters).responseJSON { response in
                if let error = response.error {
                    reject(error)
                    return
                }
                
                guard let json = response.result.value as? Json else {
                    fulfill(nil)
                    return
                }
                
                guard let address = parseAddress(json: json) else {
                    fulfill(nil)
                    return
                }
                
                fulfill(address)
            }
        }
    }
    
    private static func parseAddress(json: Json) -> Address? {
        guard let geoObjectJson = parseGeoObjectJson(json: json) else {
            return nil
        }
        
        guard let coordinate = parseCoordinate(geoObjectJson: geoObjectJson) else {
            return nil
        }
        
        guard let metaDataPropertyJson = geoObjectJson["metaDataProperty"] as? Json,
            let geocoderMetaDataJson = metaDataPropertyJson["GeocoderMetaData"] as? Json,
            let addressJson = geocoderMetaDataJson["Address"] as? Json else {
                return nil
        }
        
        guard let countryCode = addressJson["country_code"] as? String,
            let formatted = addressJson["formatted"] as? String,
            let componentsJsonArr = addressJson["Components"] as? [Json] else {
                return nil
        }
        
        var components = [AddressComponent]()
        
        for componentJson in componentsJsonArr {
            if let kind = componentJson["kind"] as? String,
                let name = componentJson["name"] as? String {
                components.append(AddressComponent(kind: kind, name: name))
            }
        }
        
        let opengisName = geoObjectJson["name"] as? String
        
        return Address(coordinate: coordinate, countryCode: countryCode,
                       formatted: formatted, components: components, opengisName: opengisName)
    }
    
    private static func parseGeoObjectJson(json: Json) -> Json? {
        guard let jsonResponse = json["response"] as? Json,
            let geoObjectCollectionJson = jsonResponse["GeoObjectCollection"] as? Json,
            let featureMemberJsonArray = geoObjectCollectionJson["featureMember"] as? [Any] else {
            return nil
        }
        
        guard featureMemberJsonArray.count > 0 else {
            return nil
        }
        
        return (featureMemberJsonArray[0] as? Json)?["GeoObject"] as? Json
    }
    
    private static func parseCoordinate(geoObjectJson: Json) -> CLLocationCoordinate2D? {
        guard let pointJson = geoObjectJson["Point"] as? Json,
            let coordinateString = pointJson["pos"] as? String else {
                return nil
        }
        
        let longlat =  coordinateString.components(separatedBy: " ")
        
        guard let longitude = Double(longlat[0]),
            let latitude = Double(longlat[1]) else {
                return nil
        }
        
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
    }
}
