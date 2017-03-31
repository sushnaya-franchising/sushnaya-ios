//
//  API.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/22/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftWebSocket

enum APIChatCommand: String {
    case menu = "/menu"
    case changeLocality = "/setcity"
    case termsOfUseUpdate = "/termsofuseupdate"
}

class APIChat: NSObject {
    static let webSocketUrl = "ws://api.sushnaya.com:8888/0.1.0"

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
        EventBus.onBackgroundThread(self, name: AskMenuEvent.name) { [unowned self] _ in
            self.ws?.send(APIChatCommand.menu.rawValue)
        }

        EventBus.onBackgroundThread(self, name: ChangeLocalityEvent.name) { [unowned self] notification in
            if let locality = (notification.object as? ChangeLocalityEvent)?.locality {
                self.ws?.send("\(APIChatCommand.changeLocality.rawValue) \(locality.name)")
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
        if let textMessage = message as? String {
            print("NEW INCOMMING MESSAGE: \(textMessage)")
            // todo: parse message and fire appropriate event

            // todo: remove simulation
            if textMessage.hasPrefix(APIChatCommand.menu.rawValue) {
                fireFakeChangeLoalitiesProposal()
            }
        }
    }

    func disconnect() {
        ws?.close()
    }
}
