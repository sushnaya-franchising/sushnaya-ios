//
//  API.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/22/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftWebSocket
import PromiseKit
import SwiftyJSON

class APIChat: NSObject {
    static let webSocketUrl = "ws://84bf451a.ngrok.io/0.1.0"

    private var ws: WebSocket?

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
            self.ws?.send(try! GetMenuDto().serializedData())
        }

        EventBus.onBackgroundThread(self, name: DidSelectMenuEvent.name) { [unowned self] notification in
            if let menu = (notification.object as? DidSelectMenuEvent)?.menu {
                var data = DidSelectMenuDto()
                data.menuID = menu.menuId
                
                self.ws?.send(try! data.serializedData())
            }
        }
    }

    private func unregisterEventHandlers() {
        EventBus.unregister(self)
    }

    func connect(authToken: String) -> Promise<()> {
        let (promise, fulfill, reject) = Promise<()>.pending()

        ws = ensureWebSocket()

        ws?.event.open = {
            fulfill()

            ConnectionDidOpenAPIChatEvent.fire()
        }

        ws?.event.error = { error in
            reject(error)

            APIChatErrorEvent.fire(error)
        }

        ws?.event.close = { code, reason, clean in
            ConnectionDidCloseAPIChatEvent.fire()
        }

        ws?.event.message = handleMessage
        ws?.binaryType = WebSocketBinaryType.nsData

        OpeningConnectionAPIChatEvent.fire()

        ws?.open(request: createConnectionRequest(authToken))

        return promise
    }

    private func createConnectionRequest(_ authToken: String) -> URLRequest {
        var request = URLRequest(url: URL(string: APIChat.webSocketUrl)!)
        request.addValue(authToken, forHTTPHeaderField: "Authorization")

        return request
    }

    private func ensureWebSocket() -> WebSocket {
        return ws == nil ? WebSocket() : ws!
    }

    private func handleMessage(message: Any?) {
        if let data = message as? Data,
            let foodServiceMsg = try? FoodServiceMessage(serializedData: data),
            let oneOfMsg = foodServiceMsg.msg {
            
            switch oneOfMsg {
            
            case .selectMenu(let dto):
                SelectMenuEvent.fire(menus: map(dto.menus))
            
            case .didUpdateTermsOfServices:
                return
            }
        }
    }

    func disconnect() {
        ws?.close()
    }
}

extension APIChat {
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
                                fiasId: dto.fiasID,
                                coatOfArmsUrl: dto.coatOfArmsURL)
    }
}
