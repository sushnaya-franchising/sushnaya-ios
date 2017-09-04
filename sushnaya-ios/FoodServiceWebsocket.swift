import Foundation
import PromiseKit
import SwiftyJSON
import Starscream

class FoodServiceWebSocket: NSObject {
    static let webSocketUrl = "ws://appnbot.ngrok.io/0.1.0"

    private var socket: WebSocket?
    
    var isConnected: Bool {
        return socket?.isConnected ?? false
    }

    // todo: map of requests to counters
    
    override init() {
        super.init()

        registerEventHandlers()
    }

    deinit {
        unregisterEventHandlers()
        disconnect()
    }

    private func registerEventHandlers() {
        EventBus.onBackgroundThread(self, name: OpenConnectionEvent.name) { [unowned self] notification in
            let authToken = (notification.object as! OpenConnectionEvent).authToken
            
            self.connect(authToken: authToken)
        }
        
        EventBus.onBackgroundThread(self, name: GetMenuEvent.name) { [unowned self] _ in
            var msg = UserMessage()
            msg.type = .getMenu(GetMenuDto())
            self.socket?.write(data: (try! msg.serializedData()))
        }

        EventBus.onBackgroundThread(self, name: DidSelectMenuEvent.name) { [unowned self] notification in
            if let menuDto = (notification.object as? DidSelectMenuEvent)?.menuDto {
                var msg = UserMessage()
                msg.type = .didSelectMenu(DidSelectMenuDto())
                msg.didSelectMenu.menuID = menuDto.menuID
                
                self.socket?.write(data: (try! msg.serializedData()))
            }
        }
    }

    private func unregisterEventHandlers() {
        EventBus.unregister(self)
    }

    func connect(authToken: String) {
        socket = WebSocket(url: URL(string: FoodServiceWebSocket.webSocketUrl)!)
        socket?.headers["Authorization"] = authToken
        
        socket?.onConnect = {
            DidOpenConnectionEvent.fire()
        }
        
        socket?.onDisconnect = { (error: NSError?) in
            if let error = error {
                DidCloseConnectionWithErrorEvent.fire(error)
            }
            
            DidCloseConnectionEvent.fire()
        }
        
        socket?.onData = handleData                

        socket?.connect()
    }

    private func handleData(data: Data) {
        if let msg = try? FoodServiceMessage(serializedData: data),
            let msgType = msg.type {
            
            switch msgType {
            
            case .selectMenu(let dto):
                SelectMenuServerEvent.fire(menus: dto.menus)
            
            case .didUpdateTermsOfServices:
                return
                
            case .categories(let dto):
                CategoriesServerEvent.fire(categories: dto.categories)
                return
                
            case .recommendations(let dto):
                RecommendationsServerEvent.fire(products: dto.products)
                return
                
            default:
                return
            }
        }
    }

    func disconnect() {
        socket?.disconnect()
    }
}
