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
}

enum APIChatError: Error {
    case connectionError(reason: String)        
}

class APIChat {
    private let authToken: String
    private let webSocketUrl: String
    private var ws: WebSocket?
    
    private init(authToken: String, webSocketUrl: String) {
        self.authToken = authToken
        self.webSocketUrl = webSocketUrl
    }
    
    static func connect(authToken: String, webSocketUrl: String) -> Promise<APIChat> {
        let chat = APIChat(authToken: authToken, webSocketUrl: webSocketUrl)
            
        return chat.connect()
    }
    
    private func connect() -> Promise<APIChat> {
        let (promise, fulfill, reject) = Promise<APIChat>.pending()
        
        ws = WebSocket()
        
        ws?.event.open = {
            self.ws?.event.error = self.handleError
            
            fulfill(self)
        }
        
        ws?.event.error = { error in
            reject(APIChatError.connectionError(reason: error.localizedDescription))
        }
        
        ws?.event.message = handleMessage
        
        ws?.open(webSocketUrl)
        
        return promise
    }
    
    private func handleMessage(message: Any?) {
        if let text = message as? String {
            SwiftEventBus.post(text)
        }
    }
    
    private func handleError(error: Error) {
        // todo: open error controller?
        
        print(error.localizedDescription)
    }
    
    func menu() {
        ws?.send("/menu")
    }
    
    func close() {
        ws?.close()
        ws = nil // break strong reference
    }
    
    deinit {
        close()
    }
}
