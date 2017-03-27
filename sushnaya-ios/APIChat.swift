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
        SwiftEventBus.onBackgroundThread(self, name: AskMenuEvent.name) { [unowned self] _ in
            self.ws?.send(APIChatCommand.menu.rawValue)
        }
        
        SwiftEventBus.onBackgroundThread(self, name: ChangeLocalityEvent.name) { [unowned self] notification in
            if let locality = (notification.object as? ChangeLocalityEvent)?.locality {
                self.ws?.send("\(APIChatCommand.changeLocality.rawValue) \(locality.name)")
            }
        }
    }
            
    private func unregisterEventHandlers() {
        SwiftEventBus.unregister(self)
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
        
        ws?.open(APIChat.webSocketUrl)
        
        return promise
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
                ChangeLocalityProposalEvent.fire(localities: [
                    Locality(location: CLLocation(latitude: 57.626569, longitude: 39.893787), name: "Ярославль", description: "Росиия",
                             boundedBy: (CLLocation(latitude: 57.525615, longitude: 39.730796),
                                         CLLocation(latitude: 57.775396, longitude: 40.003049))),
                    
                    Locality(location: CLLocation(latitude: 57.767961, longitude: 40.926858), name: "Кострома", description: "Росиия",
                        boundedBy:(CLLocation(latitude: 57.707638, longitude: 40.744482),
                                   CLLocation(latitude: 57.838285, longitude: 41.058335))),
                                   
                    Locality(location: CLLocation(latitude: 57.000348, longitude: 40.973921), name: "Иваново", description: "Росиия",
                             boundedBy:(CLLocation(latitude: 56.946683, longitude: 40.867911),
                                        CLLocation(latitude: 57.07038, longitude: 41.125476))),
                                        
                    Locality(location: CLLocation(latitude: 56.838607, longitude: 60.605514), name: "Екатеринбург", description: "Свердловская область, Россия",
                             boundedBy:(CLLocation(latitude: 56.593795, longitude: 60.263481),
                                        CLLocation(latitude: 56.982916, longitude: 60.943308))),
                    
                    Locality(location: CLLocation(latitude: 58.048454, longitude: 38.858406), name: "Рыбинск", description: "Росиия, Ярославская область",
                             boundedBy:(CLLocation(latitude: 58.001581, longitude: 38.64997),
                                        CLLocation(latitude: 58.12118, longitude: 38.975035)))
                    ])
            }
        }
    }
    
    func disconnect() {
        ws?.close()
    }
}
