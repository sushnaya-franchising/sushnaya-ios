import Foundation

struct OpenConnectionEvent: Event {
    static var name: String = "\(OpenConnectionEvent.self)"
    
    var authToken: String
    
    static func fire(authToken: String) {
        EventBus.post(OpenConnectionEvent.name, sender: OpenConnectionEvent(authToken: authToken))
    }
}

struct DidOpenConnectionEvent: Event {
    static var name: String = "\(DidOpenConnectionEvent.self)"
    
    static func fire() {
        EventBus.post(DidOpenConnectionEvent.name)
    }
}

struct DidCloseConnectionEvent: Event {
    static var name: String = "\(DidCloseConnectionEvent.self)"
    
    static func fire() {
        EventBus.post(DidCloseConnectionEvent.name)
    }
}

struct DidCloseConnectionWithErrorEvent: Event {
    static var name: String = "\(DidCloseConnectionWithErrorEvent.self)"
    
    var cause: Error
    
    static func fire(_ cause: Error) {
        EventBus.post(DidCloseConnectionWithErrorEvent.name, sender: DidCloseConnectionWithErrorEvent(cause: cause))
    }
}
