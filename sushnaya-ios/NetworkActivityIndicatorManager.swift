import Foundation

class NetworkActivityIndicatorManager {
    static let sharedInstance = NetworkActivityIndicatorManager()

    // todo: create multiple websocketCounters (one for plain http requests and images and one for websocket communication)
    private var websocketCounter = 0
    private var httpCounter = 0

    private let inicatorVisibilityDebouncer = debounce {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true        
    }
    
    init() {
        
        // connection events
        
        EventBus.onMainThread(self, name: OpenConnectionEvent.name) { [unowned self] _ in
            self.willWebsocketEvent()
        }
        
        EventBus.onMainThread(self, name: DidOpenConnectionEvent.name) { [unowned self] _ in
            self.didWebsocketEvent()
        }
        
        EventBus.onMainThread(self, name: DidCloseConnectionEvent.name) { [unowned self] _ in
            self.didCloseConnection()
        }
        
        EventBus.onMainThread(self, name: DidCloseConnectionWithErrorEvent.name) { [unowned self] _ in
            self.didCloseConnection()
        }
        
        // menu events
        
        EventBus.onMainThread(self, name: GetMenuEvent.name) { [unowned self] _ in
            self.willWebsocketEvent()
        }
        
        EventBus.onMainThread(self, name: DidSelectMenuEvent.name) { [unowned self] _ in
            self.willWebsocketEvent()
        }
        
        EventBus.onMainThread(self, name: SelectMenuServerEvent.name) { [unowned self] _ in
            self.didWebsocketEvent()
        }
        
        // address events
        
        EventBus.onMainThread(self, name: CreateAddressEvent.name) { [unowned self] _ in
            self.willWebsocketEvent()
        }
        
        EventBus.onMainThread(self, name: UpdateAddressEvent.name) { [unowned self] _ in
            self.willWebsocketEvent()
        }
        
        EventBus.onMainThread(self, name: RemoveAddressEvent.name) { [unowned self] _ in
            self.willWebsocketEvent()
        }
        
        EventBus.onMainThread(self, name: DidCreateAddressServerEvent.name) { [unowned self] _ in
            self.didWebsocketEvent()
        }
        
        EventBus.onMainThread(self, name: DidNotCreateAddressServerEvent.name) { [unowned self] _ in
            self.didWebsocketEvent()
        }
        
        EventBus.onMainThread(self, name: DidUpdateAddressServerEvent.name) { [unowned self] _ in
            self.didWebsocketEvent()
        }
        
        EventBus.onMainThread(self, name: DidNotUpdateAddressServerEvent.name) { [unowned self] _ in
            self.didWebsocketEvent()
        }
        
        EventBus.onMainThread(self, name: DidRemoveAddressServerEvent.name) { [unowned self] _ in
            self.didWebsocketEvent()
        }
        
        EventBus.onMainThread(self, name: DidNotRemoveAddressServerEvent.name) { [unowned self] _ in
            self.didWebsocketEvent()
        }
        
        // products events
        
        EventBus.onMainThread(self, name: CategoriesServerEvent.name) { [unowned self] _ in
            self.didWebsocketEvent()
        }
        
        EventBus.onMainThread(self, name: RecommendationsServerEvent.name) { [unowned self] _ in
            self.didWebsocketEvent()
        }
        
        // request sms with verification code
        
        EventBus.onMainThread(self, name: RequestSMSWithVerificationCodeEvent.name) { [unowned self] _ in
            self.willHttpEvent()
        }
        
        EventBus.onMainThread(self, name: DidRequestSMSWithVerificationCodeEvent.name) { [unowned self] _ in
            self.didHttpEvent()
        }
        
        EventBus.onMainThread(self, name: DidNotRequestAuthenticationTokenEvent.name) { [unowned self] _ in
            self.didHttpEvent()
        }
        
        // request authentication token
        
        EventBus.onMainThread(self, name: RequestAuthenticationTokenEvent.name) { [unowned self] _ in
            self.willHttpEvent()
        }
        
        EventBus.onMainThread(self, name: DidRequestAuthenticationTokenEvent.name) { [unowned self] _ in
            self.didHttpEvent()
        }
        
        EventBus.onMainThread(self, name: DidNotRequestAuthenticationTokenEvent.name) { [unowned self] _ in
            self.didHttpEvent()
        }
    }
    
    deinit {
        EventBus.unregister(self)
    }
    
    private func willWebsocketEvent() {
        websocketCounter += 1
        inicatorVisibilityDebouncer.apply()
    }
    
    private func didWebsocketEvent() {
        if websocketCounter > 0 { websocketCounter -= 1 }
        
        adjustIndicatorVisibility()
    }
    
    private func willHttpEvent() {
        httpCounter += 1
        inicatorVisibilityDebouncer.apply()
    }
    
    private func didHttpEvent() {
        if httpCounter > 0 { httpCounter -= 1 }
        
        adjustIndicatorVisibility()
    }
    
    private func didCloseConnection() {
        websocketCounter = 0
        adjustIndicatorVisibility()
    }
    
    private func adjustIndicatorVisibility() {
        if httpCounter + websocketCounter == 0 {
            inicatorVisibilityDebouncer.cancel()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
