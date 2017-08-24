//
//  API.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/22/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON
import Starscream

class FoodServiceWebSocket: NSObject {
    static let webSocketUrl = "ws://api.sushnaya.com:8080/0.1.0"

    private var socket: WebSocket?
    
    var isConnected: Bool {
        return socket?.isConnected ?? false
    }

    override init() {
        super.init()

        registerEventHandlers()
    }

    deinit {
        unregisterEventHandlers()
        disconnect()
    }

    private func registerEventHandlers() {
        EventBus.onBackgroundThread(self, name: GetMenuEvent.name) { [unowned self] _ in
            var msg = UserMessage()
            msg.type = .getMenu(GetMenuDto())
            self.socket?.write(data: (try! msg.serializedData()))
        }

        EventBus.onBackgroundThread(self, name: DidSelectMenuEvent.name) { [unowned self] notification in
            if let menu = (notification.object as? DidSelectMenuEvent)?.menu {
                var msg = UserMessage()
                msg.type = .didSelectMenu(DidSelectMenuDto())
                msg.didSelectMenu.menuID = menu.menuId
                
                self.socket?.write(data: (try! msg.serializedData()))
            }
        }
    }

    private func unregisterEventHandlers() {
        EventBus.unregister(self)
    }

    func connect(authToken: String) -> Promise<()> {
        let (promise, fulfill, _) = Promise<()>.pending()

        socket = WebSocket(url: URL(string: FoodServiceWebSocket.webSocketUrl)!)
        socket?.headers["Authorization"] = authToken
        
        socket?.onConnect = {
            fulfill()
            ConnectionDidOpenAPIChatEvent.fire()
        }
        
        socket?.onDisconnect = { (error: NSError?) in
            if let error = error {
                APIChatErrorEvent.fire(error)
            }
            
            ConnectionDidCloseAPIChatEvent.fire()
        }
        
        socket?.onData = handleData
        
        OpeningConnectionAPIChatEvent.fire()

        socket?.connect()
        
        return promise
    }

    private func handleData(data: Data) {
        if let msg = try? FoodServiceMessage(serializedData: data),
            let msgType = msg.type {
            
            switch msgType {
            
            case .selectMenu(let dto):
                SelectMenuEvent.fire(menus: map(dto.menus))
            
            case .didUpdateTermsOfServices:
                return
                
            case .categories(let dto):
                print("Categories count: \(dto.categories.count)")
                return
                
            case .recommendations(let dto):
                print("Recommended products count: \(dto.products.count)")
                return
            }
        }
    }

    func disconnect() {
        socket?.disconnect()
    }
}

extension FoodServiceWebSocket {
    func map(_ dtos: [MenuDto]) -> [Menu] {
        return dtos.map { dto in
            return Menu(menuId: dto.menuID, locality: map(dto.locality))
        }
    }
    
    func map(_ dto: LocalityDto) -> Locality {
        return Locality(location: CLLocation(latitude: dto.latitude, longitude: dto.longitude),
                                name: dto.name,
                                description: dto.descr,
                                boundedBy: (lowerCorner: CLLocation(latitude: dto.lowerLatitude, longitude: dto.lowerLongitude),
                                            upperCorner: CLLocation(latitude: dto.upperLatitude, longitude: dto.upperLongitude)),
                                fiasId: dto.fiasID)
    }
}
