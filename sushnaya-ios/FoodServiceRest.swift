import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit


class FoodServiceRest {
    static let baseUrl = "http://appnbot.ngrok.io/0.1.0"
//    static let baseUrl = "http://8555382b.ngrok.io/0.1.0"
    static let menusUrl = baseUrl + "/menus"
    static let selectMenuUrl = menusUrl + "/%d/select"
    static let categoriesUrl = menusUrl + "/%d/categories"
    static let productsUrl = baseUrl + "/categories/%d/products"
    static let addressesUrl = baseUrl + "/addresses"
    
    class func getMenus(authToken: String) -> Promise<JSON> {
        let q = DispatchQueue.global()
        let headers: HTTPHeaders = [ "Authorization": authToken ]
        
        return firstly { _ in
            Alamofire.request(menusUrl, method: .get, headers: headers).responseData()
        }.then(on: q) { data in
            JSON(data)
        }
    }
    
    class func selectMenu(menuId: Int32, authToken: String) -> Promise<JSON> {
        let q = DispatchQueue.global()
        let headers: HTTPHeaders = [ "Authorization": authToken ]
        let url = String(format: selectMenuUrl, menuId)
        
        return firstly { _ in
            Alamofire.request(url, method: .post, headers: headers).responseData()
        
        }.then(on: q) { data in
                JSON(data)
        }
    }
    
    class func getCategories(menuId: Int32, authToken: String) -> Promise<JSON> {
        let q = DispatchQueue.global()
        let headers: HTTPHeaders = [ "Authorization": authToken ]
        let url = String(format: categoriesUrl, menuId)
        
        return firstly {
            Alamofire.request(url, method: .get, headers: headers).responseData()
            
        }.then(on: q) { data in
            JSON(data)
        }
    }
    
    class func getProducts(categoryId: Int32, authToken: String) -> Promise<JSON> {
        let q = DispatchQueue.global()
        let headers: HTTPHeaders = [ "Authorization": authToken ]
        let url = String(format: productsUrl, categoryId)
        
        return firstly {
            Alamofire.request(url, method: .get, headers: headers).responseData()
            
        }.then(on: q) { data in
            JSON(data)
        }
    }
    
    class func getAddresses(authToken: String, localityId: Int32?) -> Promise<JSON> {
        let q = DispatchQueue.global()
        let headers: HTTPHeaders = [ "Authorization": authToken ]
        let parameters: Parameters? = (localityId == nil ? nil: [ "localityId": localityId! ])
        
        return firstly {
            Alamofire.request(addressesUrl, method: .get, parameters: parameters, headers: headers).responseData()
            
        }.then(on: q) { data in
            JSON(data)
        }
    }
    
    class func postAddress(address: AddressEntity, authToken: String) -> Promise<JSON> {
        let headers: HTTPHeaders = [ "Authorization": authToken ]
        var parameters: Parameters = [
            "localityId": address.locality.serverId,
            "location": [
                "latitude": address.latitude,
                "longitude": address.longitude
            ],
            "streetAndHouse": address.streetAndHouse,
            "orderCount": address.orderCount,
            ]
        
        if let id = address.serverId?.int32Value {
            parameters["id"] = id
        }
        
        if let apartment = address.apartment {
            parameters["apartment"] = apartment
        }
        
        if let entrance = address.entrance {
            parameters["entrance"] = entrance
        }
        
        if let floor = address.floor {
            parameters["floor"] = floor
        }
        
        if let comment = address.comment {
            parameters["comment"] = comment
        }
        
        return firstly {
            Alamofire.request(addressesUrl,
                              method: .post,
                              parameters: parameters,
                              encoding: JSONEncoding.default,
                              headers: headers).debugLog().responseData()
            
        }.then { data in            
            JSON(data)
        }
    }
}

extension Request {
    public func debugLog() -> Self {
        #if DEBUG
            debugPrint(self)
        #endif
        return self
    }
}

