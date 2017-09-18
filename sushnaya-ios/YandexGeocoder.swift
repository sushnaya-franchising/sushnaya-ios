import Foundation
import Alamofire
import PromiseKit

struct YandexAddress {
    var coordinate: CLLocationCoordinate2D
    var countryCode: String
    var formatted: String
    var components: [YandexAddressComponent]
    var opengisName: String?
    
    var displayName: String {
        return opengisName ?? formatted
    }
}
 
struct YandexAddressComponent {
    var kind: String
    var name: String
}
 
class YandexGeocoder {
    fileprivate typealias Json = [String: Any]
    
    static func requestAddress(query: String) -> Promise<YandexAddress?> {
        let parameters: Parameters = [
            "kind": "house",
            "results": 1,
            "format": "json",
            "geocode": "\(query)"
        ]
        
        return requestAddress(parameters: parameters)
    }
    
    static func requestAddress(coordinate: CLLocationCoordinate2D) -> Promise<YandexAddress?> {
        let parameters: Parameters = [
            "kind": "house",
            "results": 1,
            "format": "json",
            "geocode": "\(coordinate.longitude),\(coordinate.latitude)"
        ]
        
        return requestAddress(parameters: parameters)
    }
    
    static func requestAddress(parameters: Parameters) -> Promise<YandexAddress?> {
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
    
    private static func parseAddress(json: Json) -> YandexAddress? {
        guard let geoObjectJson = parseGeoObjectJson(json: json) else {
            return nil
        }
        
        guard let coordinate = parseCoordinate(geoObjectJson: geoObjectJson) else {
            return nil
        }
        
        guard let metaDataPropertyJson = geoObjectJson["metaDataProperty"] as? Json,
            let geocoderMetaDataJson = metaDataPropertyJson["GeocoderMetaData"] as? Json,
            let precision = geocoderMetaDataJson["precision"] as? String,
            let addressJson = geocoderMetaDataJson["Address"] as? Json else {
                return nil
        }
        
        guard precision == "exact" || precision == "near" else {
            return nil
        }
        
        guard let countryCode = addressJson["country_code"] as? String,
            let formatted = addressJson["formatted"] as? String,
            let componentsJsonArr = addressJson["Components"] as? [Json] else {
                return nil
        }
        
        var components = [YandexAddressComponent]()
        
        for componentJson in componentsJsonArr {
            if let kind = componentJson["kind"] as? String,
                let name = componentJson["name"] as? String {
                components.append(YandexAddressComponent(kind: kind, name: name))
            }
        }
        
        let opengisName = geoObjectJson["name"] as? String
        
        return YandexAddress(coordinate: coordinate, countryCode: countryCode,
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
    
    // todo: use YandexGeocoder custom session manager
    @discardableResult
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
