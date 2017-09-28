import Foundation
import CoreStore
import SwiftyJSON

enum CurrentCategory: Equatable {
    case Recommendations
    case Concrete(category: MenuCategoryEntity)
}

func ==(lhs: CurrentCategory, rhs: CurrentCategory)->Bool {
    switch (lhs, rhs) {
    case let (.Concrete(l), .Concrete(r)):
        return l.serverId == r.serverId
    case (.Recommendations, .Recommendations):
        return true
    default:
        return false
    }
}

class Core: ObjectObserver {
    static let Singleton = Core()
    
    let cart: Cart
    
    let settingsMonitor: ObjectMonitor<UserSettingsEntity>
    let menusMonitor: ListMonitor<MenuEntity>
    let categoriesMonitor: ListMonitor<MenuCategoryEntity>
    let productsMonitor: ListMonitor<ProductEntity>
    let addressesMonitor: ListMonitor<AddressEntity>
    let addressesByLocalityMonitor: ListMonitor<AddressEntity>
    let cartUnitsMonitor: ListMonitor<CartUnitEntity>

    var authToken: String? {
        return settingsMonitor.object?.authToken
    }

    var selectedMenuId: Int32? {
        return settingsMonitor.object?.selectedMenu?.serverId
    }
    
    fileprivate var currentCategory = CurrentCategory.Recommendations
    
    private init() {
        func createSettingsMonitor() -> ObjectMonitor<UserSettingsEntity> {
            var settings = CoreStore.fetchOne(From<UserSettingsEntity>())
            
            if settings == nil {
                
                _ = try? CoreStore.perform(
                    synchronous: { (transaction) in
                        transaction.create(Into<UserSettingsEntity>())
                })
                
                settings = CoreStore.fetchOne(From<UserSettingsEntity>())
            }
            
            return CoreStore.monitorObject(settings!)
        }
        
        func createMenusMonitor() -> ListMonitor<MenuEntity> {
            return CoreStore.monitorList(From<MenuEntity>(),
                OrderBy(.ascending(#keyPath(MenuEntity.locality.name))))
        }
        
        func createCategoriesMonitor(_ settings: UserSettingsEntity?) -> ListMonitor<MenuCategoryEntity> {
            let selectedMenuId = settings?.selectedMenu?.serverId ?? -1
            
            return CoreStore.monitorList(
                From<MenuCategoryEntity>(),
                Where("menu.serverId", isEqualTo: selectedMenuId),
                OrderBy(.ascending(#keyPath(MenuCategoryEntity.rank))) +
                    OrderBy(.ascending(#keyPath(MenuCategoryEntity.name))))
        }
        
        func createProductsMonitor(_ settings: UserSettingsEntity?) -> ListMonitor<ProductEntity> {
            let selectedMenuId: Int32 = settings?.selectedMenu?.serverId ?? -1
            
            return CoreStore.monitorList(
                From<ProductEntity>(),
                Where("category.menu.serverId", isEqualTo: selectedMenuId) &&
                    Where("isRecommended", isEqualTo: true),
                OrderBy(.ascending(#keyPath(ProductEntity.rank))) +
                    OrderBy(.ascending(#keyPath(ProductEntity.name))))
        }
        
        func createAddressesMonitor() -> ListMonitor<AddressEntity> {
            return CoreStore.monitorList(
                From<AddressEntity>(),
                OrderBy(.ascending(#keyPath(AddressEntity.orderCount))) +
                OrderBy(.ascending(#keyPath(AddressEntity.timestamp))) +
                    OrderBy(.ascending(#keyPath(AddressEntity.streetAndHouse))))
        }
        
        func createAddressesByLocalityMonitor(_ settings: UserSettingsEntity?) -> ListMonitor<AddressEntity> {
            let localityId: Int32 = settings?.selectedMenu?.locality.serverId ?? -1
            
            return CoreStore.monitorList(
                From<AddressEntity>(),
                Where("locality.serverId", isEqualTo: localityId),
                OrderBy(.ascending(#keyPath(AddressEntity.orderCount))) +
                OrderBy(.ascending(#keyPath(AddressEntity.timestamp))) +
                    OrderBy(.ascending(#keyPath(AddressEntity.streetAndHouse))))
        }
        
        func createCartUnitsMonitor() -> ListMonitor<CartUnitEntity> {
            return CoreStore.monitorList(
                From<CartUnitEntity>(),
                OrderBy(.descending(#keyPath(CartUnitEntity.addedAt))))
        }
        
        CoreStore.defaultStack = DataStack(xcodeModelName: "Appnbot")
        
        do {
            try CoreStore.addStorageAndWait(SQLiteStore(fileName: "Appnbot.sqlite"))
        } catch {
            // todo: report fatal error
        }
        
        self.settingsMonitor = createSettingsMonitor()
        self.menusMonitor = createMenusMonitor()
        self.categoriesMonitor = createCategoriesMonitor(self.settingsMonitor.object)
        self.productsMonitor = createProductsMonitor(self.settingsMonitor.object)
        self.addressesMonitor = createAddressesMonitor()
        self.addressesByLocalityMonitor = createAddressesByLocalityMonitor(self.settingsMonitor.object)
        self.cartUnitsMonitor = createCartUnitsMonitor()
        
        cart = Cart(cartUnitsMonitor: cartUnitsMonitor)
        
        self.settingsMonitor.addObserver(self)
        
        bindEventHandlers()
    }

    private func bindEventHandlers() {
        EventBus.onMainThread(self, name: SyncMenusEvent.name) { notification in
            if let menusJSON = (notification.object as! SyncMenusEvent).menusJSON.array {
                
                do {
                    _ = try CoreStore.perform(synchronous: { [unowned self] (transaction) in
                        try! self.deleteDeprecatedMenus(update: menusJSON, in: transaction)
                        
                        guard menusJSON.count > 0 else {
                            transaction.edit(self.settingsMonitor.object)!.selectedMenu = nil
                            return
                        }
                        
                        _ = try! transaction.importUniqueObjects(Into<MenuEntity>(), sourceArray: menusJSON)
                    })
                } catch {
                    // todo: log corestore error
                }
                
                DidSyncMenusEvent.fire()
            }
        }

        EventBus.onMainThread(self, name: SyncCategoriesEvent.name) { notification in
            let event = (notification.object as! SyncCategoriesEvent)
            let menuId = event.menuId
            
            if let categoriesJSON = event.categoriesJSON.array {
                do {
                    _ = try CoreStore.perform(synchronous: { [unowned self] (transaction) in
                        try! self.deleteDeprecatedCategories(update: categoriesJSON, inMenu: menuId, in: transaction)
                        
                        guard categoriesJSON.count > 0 else { return }
                        
                        _ = try! transaction.importUniqueObjects(Into<MenuCategoryEntity>(), sourceArray: categoriesJSON)
                    })
                } catch {
                    // todo: log corestore error
                }
            }
        }
        
        EventBus.onMainThread(self, name: SyncProductsEvent.name) { notification in
            let event = (notification.object as! SyncProductsEvent)
            let categoryId = event.categoryId
            
            if let productsJSON = event.productsJSON.array {
                do {
                    _ = try CoreStore.perform(synchronous: { [unowned self] (transaction) in
                        try! self.deleteDeprecatedProducts(update: productsJSON, inCategory: categoryId, in: transaction)
                        
                        guard productsJSON.count > 0 else { return }
                        
                        _ = try! transaction.importUniqueObjects(Into<ProductEntity>(), sourceArray: productsJSON)
                    })
                } catch {
                    // todo: log corestore error
                }
            }
        }
        
        EventBus.onMainThread(self, name: SyncAddressesEvent.name) { notification in
            let event = (notification.object as! SyncAddressesEvent)
        
            if let addressesJSON = event.addressesJSON.array {
                do {
                    _ = try CoreStore.perform(synchronous: { [unowned self] (transaction) in
                        //try! self.deleteDeprecatedAddresses(update: addressesJSON, localityId: event.localityId, in: transaction)
        
                        //guard addressesJSON.count > 0 else { return }
        
                        //_ = try! transaction.importUniqueObjects(Into<AddressEntity>(), sourceArray: addressesJSON)
                    })
                } catch {
                    // todo: log corestore error
                }
            }
        }
        
        EventBus.onMainThread(self, name: DidSelectMenuEvent.name) { [unowned self] notification in
            let menuJSON = (notification.object as! DidSelectMenuEvent).menuJSON
            
            do {
                try CoreStore.perform(synchronous: { [unowned self] (transaction) in
                    if let userSettings = transaction.edit(self.settingsMonitor.object),
                        let menu = try! transaction.importObject(Into<MenuEntity>(), source: menuJSON) {
                        userSettings.selectedMenu = menu
                    }
                })
            } catch let error {
                // todo: log error
                print(error.localizedDescription)
            }
        }
        
        EventBus.onMainThread(self, name: DidSelectCategoryEvent.name) { [unowned self] notification in
            if let category = (notification.object as! DidSelectCategoryEvent).category {
                guard self.currentCategory != CurrentCategory.Concrete(category: category) else {
                    return
                }
                
                self.currentCategory = CurrentCategory.Concrete(category: category)
                
                self.productsMonitor.refetch(
                    Where("category.serverId", isEqualTo: category.serverId),
                    OrderBy(.ascending(#keyPath(ProductEntity.rank))) +
                        OrderBy(.ascending(#keyPath(ProductEntity.name))))
            }
        }

        EventBus.onMainThread(self, name: DidSelectRecommendationsEvent.name) { [unowned self] notification in
            guard self.currentCategory != CurrentCategory.Recommendations else {
                return
            }
            
            self.currentCategory = CurrentCategory.Recommendations
            
            self.productsMonitor.refetch(
                Where("category.menu.serverId", isEqualTo: self.selectedMenuId) &&
                    Where("isRecommended", isEqualTo: true),
                OrderBy(.ascending(#keyPath(ProductEntity.rank))) +
                    OrderBy(.ascending(#keyPath(ProductEntity.name))))
        }
        
        EventBus.onMainThread(self, name: RemoveAddressEvent.name) { notification in
            let address = (notification.object as! RemoveAddressEvent).address
            
            do {
                try CoreStore.perform(synchronous: { (transaction) in
                    transaction.delete(address)
                })
                
                DidRemoveAddressEvent.fire()
            } catch let error {
                // todo: log error
                print(error.localizedDescription)
            }
        }
    }

    deinit {
        self.settingsMonitor.removeObserver(self)
    }
    
    func objectMonitor(_ monitor: ObjectMonitor<UserSettingsEntity>, didUpdateObject object: UserSettingsEntity, changedPersistentKeys: Set<RawKeyPath>) {
        if changedPersistentKeys.contains(#keyPath(UserSettingsEntity.selectedMenu)) {
            categoriesMonitor.refetch(
                Where("menu.serverId", isEqualTo: selectedMenuId ?? -1),
                OrderBy(.ascending(#keyPath(MenuCategoryEntity.rank))) +
                    OrderBy(.ascending(#keyPath(MenuCategoryEntity.name))))
            
            productsMonitor.refetch(
                Where("category.menu.serverId", isEqualTo: selectedMenuId ?? -1) &&
                    Where("isRecommended", isEqualTo: true),
                OrderBy(.ascending(#keyPath(ProductEntity.rank))) +
                    OrderBy(.ascending(#keyPath(ProductEntity.name))))
        }
    }
}

extension Core {
    func persistAuthToken(_ authToken: String) {
        do {
            try CoreStore.perform(synchronous: { [unowned self] (transaction) in
                if let settings = transaction.edit(self.settingsMonitor.object) {
                    settings.authToken = authToken
                }
            })
        } catch {
            // todo: log error
        }
    }
    
    func fetchMenu(by location: CLLocation) -> MenuEntity? {
        return CoreStore.fetchOne(
            From<MenuEntity>(),
            Where("locality.lowerLatitude <= %f", location.coordinate.latitude) &&
                Where("locality.upperLatitude >= %f", location.coordinate.latitude) &&
                Where("locality.lowerLongitude <= %f", location.coordinate.longitude) &&
                Where("locality.upperLongitude >= %f", location.coordinate.longitude))
    }
    
    fileprivate func deleteDeprecatedMenus(update: [JSON], in transaction: BaseDataTransaction) throws {
        guard let currentMenus = transaction.fetchAll(
            From<MenuEntity>(),
            OrderBy(.ascending(#keyPath(MenuEntity.serverId)))) else { return }
        
        for currentMenu in currentMenus {
            if update.filter({$0["id"].int32! == currentMenu.serverId}).first == nil {
                transaction.delete(currentMenu)
                
                if let selectedMenuId = self.selectedMenuId,
                    currentMenu.serverId == selectedMenuId {
                    transaction.edit(settingsMonitor.object)?.selectedMenu = nil
                }
            }
        }
    }
    
    fileprivate func deleteDeprecatedCategories(update: [JSON], inMenu menuId: Int32, in transaction: BaseDataTransaction) throws {
        guard let currentCategories = transaction.fetchAll(
            From<MenuCategoryEntity>(),
            Where("menu.serverId", isEqualTo: menuId),
            OrderBy(.ascending(#keyPath(MenuCategoryEntity.serverId)))) else { return }
        
        for currentCategory in currentCategories {
            if update.filter({$0["id"].int32! == currentCategory.serverId}).first == nil {
                transaction.delete(currentCategory)
            }
        }
    }
    
    fileprivate func deleteDeprecatedProducts(update: [JSON], inCategory categoryId: Int32, in transaction: BaseDataTransaction) throws {
        guard let currentProducts = transaction.fetchAll(
            From<ProductEntity>(),
            Where("category.serverId", isEqualTo: categoryId),
            OrderBy(.ascending(#keyPath(ProductEntity.serverId)))) else { return }
        
        for currentProduct in currentProducts {
            if update.filter({$0["id"].int32! == currentProduct.serverId}).first == nil {
                transaction.delete(currentProduct)
            }
        }
    }
    
    fileprivate func deleteDeprecatedAddresses(update: [JSON], localityId: Int32?, in transaction: BaseDataTransaction) throws {
        var fetchClause: [FetchClause] = [OrderBy(.ascending(#keyPath(AddressEntity.streetAndHouse)))]
        
        if let localityId = localityId {
            fetchClause.append(Where("locality.serverId", isEqualTo: localityId))
        }
        
        guard let currentAddresses = transaction.fetchAll(From<AddressEntity>(), fetchClause) else { return }
        
        for currentAddress in currentAddresses {
            guard let currentAddressId = currentAddress.serverId?.int32Value else {                
                continue
            }
            
            if update.filter({$0["id"].int32! == currentAddressId}).first == nil {
                transaction.delete(currentAddress)
            }
        }
    }
}
