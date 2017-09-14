import Foundation
import Alamofire
import SwiftyJSON

class FoodServiceRest {
    static let baseUrl = "http://localhost:8080/0.1.0"
    static let menusUrl = baseUrl + "/menus"

    
    class func requestMenus(authToken: String) {
        let headers: HTTPHeaders = [
            "Authorization": authToken,
        ]

        Alamofire.request(menusUrl, method: .get, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let data):
                DidRequestMenusEvent.fire(menusJSON: JSON(data))
                
            case .failure(let error):
                print(error) // todo: handle get menus response error
            }
        }
    }
}
