import Foundation
import Alamofire
import SwiftyJSON

class FoodServiceRest {
    static let baseUrl = "http://localhost:8080/0.1.0"
    static let menusUrl = baseUrl + "/menus"
    static let selectMenuUrl = menusUrl + "/%d/select"
    static let categoriesUrl = menusUrl + "/%d/categories"
    static let productsUrl = baseUrl + "/categories/%d/products"
    
    class func requestMenus(authToken: String) {
        let headers: HTTPHeaders = [ "Authorization": authToken ]

        Alamofire.request(menusUrl, method: .get, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let data):
                SyncMenusEvent.fire(menusJSON: JSON(data))
                
            case .failure(let error):
                print(error) // todo: handle get menus response error
                
                // todo: fire failed to request menus
            }
        }
    }
    
    class func requestSelectMenu(menuId: Int32, authToken: String) {
        let headers: HTTPHeaders = [ "Authorization": authToken ]
        
        Alamofire.request(String(format: selectMenuUrl, menuId), method: .post, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let data):
                DidSelectMenuEvent.fire(menuJSON: JSON(data))
                
            case .failure(let error):
                print(error) // todo: handle select menu response error
                
                // todo: fire failed to select menu
            }
        }
    }
    
    class func requestCategories(menuId: Int32, authToken: String) {
        let headers: HTTPHeaders = [ "Authorization": authToken ]
        
        Alamofire.request(String(format: categoriesUrl, menuId), method: .get, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let data):
                SyncCategoriesEvent.fire(categoriesJSON: JSON(data), menuId: menuId)
                
            case .failure(let error):
                print(error) // todo: handle categories response error
                
                // todo: fire failed to select menu
            }
        }
    }
    
    class func requestProducts(categoryId: Int32, authToken: String) {
        let headers: HTTPHeaders = [ "Authorization": authToken ]
        
        Alamofire.request(String(format: productsUrl, categoryId), method: .get, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let data):
                SyncProductsEvent.fire(productsJSON: JSON(data), categoryId: categoryId)
                
            case .failure(let error):
                print(error) // todo: handle categories response error
                
                // todo: fire failed to select menu
            }
        }
    }
}
