import Foundation
import SwiftyJSON


struct DidEditAddressEvent: Event {
    static var name: String = "\(DidEditAddressEvent.self)"
    
    static func fire() {
        EventBus.post(DidEditAddressEvent.name, sender: DidEditAddressEvent())
    }
}

struct DidCreateAddressServerEvent: Event {
    static var name: String = "\(DidCreateAddressServerEvent.self)"
    
    var address: Address
    
    static func fire(address: Address) {
        EventBus.post(DidCreateAddressServerEvent.name, sender: DidCreateAddressServerEvent(address: address))
    }
}

struct DidNotCreateAddressEvent: Event {
    static var name: String = "\(DidNotCreateAddressEvent.self)"
    
    var address: Address
    var error: Error
    
    static func fire(address: Address, error: Error) {
        EventBus.post(DidNotCreateAddressEvent.name, sender: DidNotCreateAddressEvent(address: address, error: error))
    }
}


struct DidNotCreateAddressServerEvent: Event {
    static var name: String = "\(DidNotCreateAddressServerEvent.self)"
    
    var address: Address
    var error: String
    
    static func fire(address: Address, error: String) {
        EventBus.post(DidNotCreateAddressServerEvent.name, sender: DidNotCreateAddressServerEvent(address: address, error: error))
    }
}

struct RemoveAddressEvent: Event {
    static var name: String = "\(RemoveAddressEvent.self)"
    
    var address: AddressEntity
    
    static func fire(address: AddressEntity) {
        EventBus.post(RemoveAddressEvent.name, sender: RemoveAddressEvent(address: address))
    }
}

struct DidRemoveAddressEvent: Event {
    static var name: String = "\(DidRemoveAddressEvent.self)"
    
    static func fire() {
        EventBus.post(DidRemoveAddressEvent.name, sender: DidRemoveAddressEvent())
    }
}

struct DidNotRemoveAddressEvent: Event {
    static var name: String = "\(DidNotRemoveAddressEvent.self)"
    
    var addressId: Int
    var error: Error
    
    static func fire(addressId: Int, error: Error) {
        EventBus.post(DidNotRemoveAddressEvent.name, sender: DidNotRemoveAddressEvent(addressId: addressId, error: error))
    }
}


struct DidRemoveAddressServerEvent: Event {
    static var name: String = "\(DidRemoveAddressServerEvent.self)"
    
    var addressId: Int
    
    static func fire(addressId: Int) {
        EventBus.post(DidRemoveAddressServerEvent.name, sender: DidRemoveAddressServerEvent(addressId: addressId))
    }
}

struct DidNotRemoveAddressServerEvent: Event {
    static var name: String = "\(DidNotRemoveAddressServerEvent.self)"
    
    var addressId: Int
    var error: String
    
    static func fire(addressId: Int, error: String) {
        EventBus.post(DidNotRemoveAddressServerEvent.name, sender: DidNotRemoveAddressServerEvent(addressId: addressId, error: error))
    }
}

struct ShowEditAddressViewControllerEvent: Event {
    static var name: String = "\(ShowEditAddressViewControllerEvent.self)"
    
    var address: AddressEntity
    
    static func fire(address: AddressEntity) {
        EventBus.post(ShowEditAddressViewControllerEvent.name, sender: ShowEditAddressViewControllerEvent(address: address))
    }
}

struct SyncAddressesEvent: Event {
    static var name: String = "\(SyncAddressesEvent.self)"
    
    var addressesJSON: JSON
    var localityId: Int32?
    
    static func fire(addressesJSON: JSON, localityId: Int32?) {
        EventBus.post(SyncAddressesEvent.name, sender: SyncAddressesEvent(addressesJSON: addressesJSON, localityId: localityId))
    }
}
