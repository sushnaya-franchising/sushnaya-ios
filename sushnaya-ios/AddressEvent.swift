//
//  CreateAddressEvent.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 8/26/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

struct CreateAddressEvent: Event {
    static var name: String = "\(CreateAddressEvent.self)"
    
    var address: Address
    
    static func fire(address: Address) {
        EventBus.post(CreateAddressEvent.name, sender: CreateAddressEvent(address: address))
    }
}

struct DidCreateAddressEvent: Event {
    static var name: String = "\(DidCreateAddressEvent.self)"
    
    var address: Address
    
    static func fire(address: Address) {
        EventBus.post(DidCreateAddressEvent.name, sender: DidCreateAddressEvent(address: address))
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

struct UpdateAddressEvent: Event {
    static var name: String = "\(UpdateAddressEvent.self)"
    
    var address: Address
    
    static func fire(address: Address) {
        EventBus.post(UpdateAddressEvent.name, sender: UpdateAddressEvent(address: address))
    }
}

struct DidUpdateAddressEvent: Event {
    static var name: String = "\(DidUpdateAddressEvent.self)"
    
    var address: Address
    
    static func fire(address: Address) {
        EventBus.post(DidUpdateAddressEvent.name, sender: DidUpdateAddressEvent(address: address))
    }
}

struct DidNotUpdateAddressEvent: Event {
    static var name: String = "\(DidNotUpdateAddressEvent.self)"
    
    var address: Address
    var error: Error
    
    static func fire(address: Address, error: Error) {
        EventBus.post(DidNotUpdateAddressEvent.name, sender: DidNotUpdateAddressEvent(address: address, error: error))
    }
}


struct DidUpdateAddressServerEvent: Event {
    static var name: String = "\(DidUpdateAddressServerEvent.self)"
    
    var address: Address
    
    static func fire(address: Address) {
        EventBus.post(DidUpdateAddressServerEvent.name, sender: DidUpdateAddressServerEvent(address: address))
    }
}

struct DidNotUpdateAddressServerEvent: Event {
    static var name: String = "\(DidNotUpdateAddressServerEvent.self)"
    
    var address: Address
    var error: String
    
    static func fire(address: Address, error: String) {
        EventBus.post(DidNotUpdateAddressServerEvent.name, sender: DidNotUpdateAddressServerEvent(address: address, error: error))
    }
}

struct RemoveAddressEvent: Event {
    static var name: String = "\(RemoveAddressEvent.self)"
    
    var addressId: Int
    
    static func fire(addressId: Int) {
        EventBus.post(RemoveAddressEvent.name, sender: RemoveAddressEvent(addressId: addressId))
    }
}

struct DidRemoveAddressEvent: Event {
    static var name: String = "\(DidRemoveAddressEvent.self)"
    
    var addressId: Int
    
    static func fire(addressId: Int) {
        EventBus.post(DidRemoveAddressEvent.name, sender: DidRemoveAddressEvent(addressId: addressId))
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
    
    var address: Address
    
    static func fire(address: Address) {
        EventBus.post(ShowEditAddressViewControllerEvent.name, sender: ShowEditAddressViewControllerEvent(address: address))
    }
}


