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
import SwiftEventBus

enum APIChatCommand: String {
    case menu = "/menu"
    
    case changeLocality = "/changecity"
    
    case termsOfUseUpdate = "/termsofuseupdate"
}

enum APIChatError: Error {
    case connectionError(reason: String)        
}

class APIChat: NSObject {
    //    static let webSocketUrl = "wss://sushnaya.com:8080/0.1.0/"
    static let webSocketUrl = "wss://echo.websocket.org"
    
    private var ws: WebSocket?
    
    override init() {
        super.init()
    }
    
    func connect(authToken: String) -> Promise<()> {
        let (promise, fulfill, reject) = Promise<()>.pending()
        
        guard ws == nil else {
            fulfill()
            
            return promise
        }
        
        ws = WebSocket()
        
        ws?.event.open = {
            self.ws?.event.error = self.handleError
            
            fulfill()
        }
        
        ws?.event.error = { error in
            reject(APIChatError.connectionError(reason: error.localizedDescription))
        }
        
        ws?.event.message = handleMessage
        
        ws?.open(APIChat.webSocketUrl)
        
        return promise
    }
    
    private func handleMessage(message: Any?) {
        if let _ = message as? String {
            // todo: parse message and fire appropriate event
        }
    }
    
    private func handleError(error: Error) {
        // todo: open error controller?
        
        print(error.localizedDescription)
    }
    
    func disconnect() {
        ws?.close()
        ws = nil // break strong reference
    }
    
    deinit {
        SwiftEventBus.unregister(self)
        
        disconnect()
    }
}
