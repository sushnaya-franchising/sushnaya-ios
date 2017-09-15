import Foundation
import Alamofire
import SwiftyJSON

class FoodServiceRest {
    static let baseUrl = "http://localhost:8080/0.1.0"
    static let menusUrl = baseUrl + "/menus"
    static let selectMenu = menusUrl + "/%d/select"
    
    // http://localhost:8080/0.1.0/menus/1/select
    
    class func requestMenus(authToken: String) {
        let headers: HTTPHeaders = [
            "Authorization": authToken,
        ]

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
    
    class func requestSelectMenu(menu: MenuEntity, authToken: String) {
        let headers: HTTPHeaders = [
            "Authorization": authToken,
        ]
        
        print(String(format: selectMenu, menu.serverId))
        
        Alamofire.request(String(format: selectMenu, menu.serverId), method: .post, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let data):
                DidSelectMenuEvent.fire(menuJSON: JSON(data).array![0])// todo: remove .array![0]
                
            case .failure(let error):
                print(error) // todo: handle select menu response error
                
                // todo: fire failed to select menu
            }
        }
        //DidSelectMenuEvent.fire(menu: menu, )
    }
}
