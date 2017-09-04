import Foundation
import SwiftEventBus
import CoreStore

class UserSession: NSObject {
    var isLoggedIn:Bool {
        get {
            return settings.authToken != nil
        }
    }

    var menu: MenuEntity?
    
    let settings: UserSettingsEntity = {
        var settings = CoreStore.fetchOne(From<UserSettingsEntity>())
        if settings == nil {
            
            _ = try? CoreStore.perform(
                synchronous: { (transaction) in
                    
                let settings = transaction.create(Into<UserSettingsEntity>())
            })
            
            settings = CoreStore.fetchOne(From<UserSettingsEntity>())
        }
        
        return settings!
    }()

    let cart = Cart()
    
    override init() {
        super.init()
        
        self.menu = CoreStore.fetchOne(From<MenuEntity>())
        
        bindEventHandlers()
    }
        
    deinit {
        EventBus.unregister(self)
    }
        
    private func bindEventHandlers() {
        EventBus.onMainThread(self, name: DidSelectMenuEvent.name) { [unowned self] notification in
            let menuDto = (notification.object as! DidSelectMenuEvent).menuDto
            
            do {
                try CoreStore.perform(synchronous: { [unowned self] (transaction) in
                    let menu = transaction.edit(self.menu) ?? transaction.create(Into<MenuEntity>())
                    menu.locality = transaction.edit(menu.locality) ?? transaction.create(Into<LocalityEntity>())
                    
                    menu.serverId = NSNumber.init(value: menuDto.menuID)
                    menu.locality.name = menuDto.locality.name
                    menu.locality.descr = menuDto.locality.descr
                    menu.locality.fiasId = menuDto.locality.fiasID                    
                    menu.locality.latitude = menuDto.locality.latitude
                    menu.locality.longitude = menuDto.locality.longitude
                    menu.locality.lowerLatitude = menuDto.locality.lowerLatitude
                    menu.locality.lowerLongitude = menuDto.locality.lowerLongitude
                    menu.locality.upperLatitude = menuDto.locality.upperLatitude
                    menu.locality.upperLongitude = menuDto.locality.upperLongitude
                })
            } catch {
                // todo: log error
            }
        }
    }
}


//    private(set) var addresses = Set<Address>()

//    init() {
//        bindEventHandlers()
//    }
//
//    deinit {
//        EventBus.unregister(self)
//    }
//
//    private func bindEventHandlers() {
//        EventBus.onMainThread(self, name: DidSelectMenuEvent.name) { [unowned self] notification in
//            self.menu = (notification.object as? DidSelectMenuEvent)?.menu
//        }

//        EventBus.onMainThread(self, name: CreateAddressEvent.name) { [unowned self] notification in
//            let address = (notification.object as! CreateAddressEvent).address
//
//            if let alreadyStored = self.addresses.filter({$0.equals(other: address)}).first {
//                DidCreateAddressEvent.fire(address: alreadyStored)
//                return
//            }
//
//            do {
//                let created = try self.addAddress(address)
//                DidCreateAddressEvent.fire(address: created)
//
//            } catch let error {
//                DidNotCreateAddressEvent.fire(address: address, error: error)
//            }
//        }
//
//        EventBus.onMainThread(self, name: UpdateAddressEvent.name) { [unowned self] notification in
//            let address = (notification.object as! UpdateAddressEvent).address
//
//            do {
//                let updated = try self.updateAddress(address)
//                DidUpdateAddressEvent.fire(address: updated)
//
//            } catch let error {
//                DidNotUpdateAddressEvent.fire(address: address, error: error)
//            }
//        }
//
//        EventBus.onMainThread(self, name: RemoveAddressEvent.name) { [unowned self] notification in
//            let addressId = (notification.object as! RemoveAddressEvent).addressId
//
//            do {
//                try self.removeAddress(addressId)
//                DidRemoveAddressEvent.fire(addressId: addressId)
//
//            } catch let error {
//                DidNotRemoveAddressEvent.fire(addressId: addressId, error: error)
//            }
//        }

// todo: increment orders count by address for every new order event (server should send address update event)
//    }

//    private func addAddress(_ address: Address) throws -> Address {
//        if let id = address.id,
//            let _ = addresses.filter({ $0.id! == id }).first {
//            throw AddressError.AddressAlreadyAdded
//        }
//
//        if address.id == nil {
//            address.setId(UserSettings.AddressId)
//            UserSettings.AddressId += 1
//        }
//
//        self.addresses.insert(address)
//
//        return address
//    }

//    private func updateAddress(_ address: Address) throws -> Address {
//        if let id = address.id,
//            let existingAddress = addresses.filter({ $0.id! == id }).first {
//            addresses.remove(existingAddress)
//            addresses.insert(address)
//
//            return address
//
//        } else {
//            throw AddressError.NoSuchAddress
//        }
//    }

//    private func removeAddress(_ id: Int) throws {
//        if let existingAddress = addresses.filter({ $0.id! == id }).first {
//            addresses.remove(existingAddress)
//
//        } else {
//            throw AddressError.NoSuchAddress
//        }
//    }

