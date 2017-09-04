import Foundation
import SwiftEventBus

struct RequestSMSWithVerificationCodeEvent: Event {
    static var name: String = "\(RequestSMSWithVerificationCodeEvent.self)"
    
    var phoneNumber: String
    
    static func fire(phoneNumber: String) {
        EventBus.post(RequestSMSWithVerificationCodeEvent.name, sender: RequestSMSWithVerificationCodeEvent(phoneNumber: phoneNumber))
    }
}

struct DidRequestSMSWithVerificationCodeEvent: Event {
    static var name: String = "\(DidRequestSMSWithVerificationCodeEvent.self)"
    
    var phoneNumber: String
    
    static func fire(phoneNumber: String) {
        EventBus.post(DidRequestSMSWithVerificationCodeEvent.name, sender: DidRequestSMSWithVerificationCodeEvent(phoneNumber: phoneNumber))
    }
}

struct DidNotRequestSMSWithVerificationCodeEvent: Event {
    static var name: String = "\(DidNotRequestSMSWithVerificationCodeEvent.self)"
    
    var error: Error
    
    static func fire(error: Error) {
        EventBus.post(DidNotRequestSMSWithVerificationCodeEvent.name, sender: DidNotRequestSMSWithVerificationCodeEvent(error: error))
    }
}

struct RequestAuthenticationTokenEvent: Event {
    static var name: String = "\(RequestAuthenticationTokenEvent.self)"
    
    var phoneNumber: String
    var code: String
    
    static func fire(phoneNumber: String, code: String) {
        EventBus.post(RequestAuthenticationTokenEvent.name, sender: RequestAuthenticationTokenEvent(phoneNumber: phoneNumber, code: code))
    }
}

struct DidRequestAuthenticationTokenEvent: Event {
    static var name: String = "\(DidRequestAuthenticationTokenEvent.self)"
    
    var authToken: String
    
    static func fire(authToken: String) {
        EventBus.post(DidRequestAuthenticationTokenEvent.name, sender: DidRequestAuthenticationTokenEvent(authToken: authToken))
    }
}

struct DidNotRequestAuthenticationTokenEvent: Event {
    static var name: String = "\(DidNotRequestAuthenticationTokenEvent.self)"
    
    var error: Error
    
    static func fire(error: Error) {
        EventBus.post(DidNotRequestAuthenticationTokenEvent.name, sender: DidNotRequestAuthenticationTokenEvent(error: error))
    }
}
