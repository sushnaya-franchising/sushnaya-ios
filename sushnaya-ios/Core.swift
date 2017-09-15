import Foundation
import CoreStore
import SwiftyJSON

class Core: ObjectObserver{
    static let Singleton = Core()
    
    let settings: ObjectMonitor<UserSettingsEntity>
    let menus: ListMonitor<MenuEntity>
    let categories: ListMonitor<MenuCategoryEntity>
    let products: ListMonitor<ProductEntity>

    var authToken: String? {
        return settings.object?.authToken
    }

    var selectedMenuId: Int32? {
        return settings.object?.selectedMenu?.serverId
    }
    
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
        
        
        CoreStore.defaultStack = DataStack(xcodeModelName: "Appnbot")
        
        do {
            try CoreStore.addStorageAndWait(SQLiteStore(fileName: "Appnbot.sqlite"))
        } catch {
            // todo: report fatal error
        }
        
        self.settings = createSettingsMonitor()
        self.menus = createMenusMonitor()
        self.categories = createCategoriesMonitor(self.settings.object)
        self.products = createProductsMonitor(self.settings.object)
        
        self.settings.addObserver(self)

        bindEventHandlers()
    }

    private func bindEventHandlers() {
        EventBus.onMainThread(self, name: SyncMenusEvent.name) { notification in
            if let menusJSON = (notification.object as! SyncMenusEvent).menusJSON.array {
                
                do {
                    _ = try CoreStore.perform(synchronous: { [unowned self] (transaction) in
                        try! self.deleteDeprecatedMenus(update: menusJSON, in: transaction)
                        
                        guard menusJSON.count > 0 else {
                            transaction.edit(self.settings.object)!.selectedMenu = nil
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
        
        EventBus.onMainThread(self, name: DidSelectMenuEvent.name) { [unowned self] notification in
            let menuJSON = (notification.object as! DidSelectMenuEvent).menuJSON
            
            do {
                try CoreStore.perform(synchronous: { [unowned self] (transaction) in
                    if let userSettings = transaction.edit(self.settings.object),
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
                self.products.refetch(
                    Where("category.serverId", isEqualTo: category.serverId),
                    OrderBy(.ascending(#keyPath(ProductEntity.rank))) +
                        OrderBy(.ascending(#keyPath(ProductEntity.name))))
            }
        }

        EventBus.onMainThread(self, name: DidSelectRecommendationsEvent.name) { [unowned self] notification in
            self.products.refetch(
                Where("category.menu.serverId", isEqualTo: self.selectedMenuId) &&
                    Where("isRecommended", isEqualTo: true),
                OrderBy(.ascending(#keyPath(ProductEntity.rank))) +
                    OrderBy(.ascending(#keyPath(ProductEntity.name))))
        }
    }

    deinit {
        self.settings.removeObserver(self)
    }
    
    func objectMonitor(_ monitor: ObjectMonitor<UserSettingsEntity>, didUpdateObject object: UserSettingsEntity, changedPersistentKeys: Set<KeyPath>) {
        if changedPersistentKeys.contains(#keyPath(UserSettingsEntity.selectedMenu)) {            
            categories.refetch(
                Where("menu.serverId", isEqualTo: selectedMenuId ?? -1),
                OrderBy(.ascending(#keyPath(MenuCategoryEntity.rank))) +
                    OrderBy(.ascending(#keyPath(MenuCategoryEntity.name))))
            
            products.refetch(
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
                if let settings = transaction.edit(self.settings.object) {
                    settings.authToken = authToken
                }
            })
        } catch {
            // todo: log error
        }
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
                    transaction.edit(settings.object)?.selectedMenu = nil
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
    
    func fetchMenu(by location: CLLocation) -> MenuEntity? {
        return CoreStore.fetchOne(
            From<MenuEntity>(),
            Where("locality.lowerLatitude <= %f", location.coordinate.latitude) &&
            Where("locality.upperLatitude >= %f", location.coordinate.latitude) &&
            Where("locality.lowerLongitude <= %f", location.coordinate.longitude) &&
            Where("locality.upperLongitude >= %f", location.coordinate.longitude))
    }
//    func selectMenu(menuDto: MenuDto) {
//        do {
//            try CoreStore.perform(synchronous: { [unowned self] (transaction) in
//                transaction.delete(self.settings.object?.selectedMenu)
//
//                let menu = self.persistMenu(menuDto: menuDto, transaction: transaction)
//
//                self.persistCategories(categoryDtos: menuDto.categories, menu: menu, transaction: transaction)
//
//                let userSettings = transaction.edit(self.settings.object)
//                userSettings?.selectedMenu = menu
//            })
//        } catch {
//            // todo: log error
//        }
//
//        DidSelectMenuEvent.fire(menuDto: menuDto)
//    }
    
//    func persistMenu(menuDto: MenuDto, transaction: BaseDataTransaction) -> MenuEntity {
//        let menu = transaction.fetchOne(
//            From<MenuEntity>(),
//            Where("serverId", isEqualTo: menuDto.menuID)) ?? transaction.create(Into<MenuEntity>())
//        menu.locality = transaction.edit(menu.locality) ?? transaction.create(Into<LocalityEntity>())
//        menu.serverId = menuDto.menuID
//        menu.locality.name = menuDto.locality.name
//        menu.locality.descr = menuDto.locality.descr
//        menu.locality.fiasId = menuDto.locality.fiasID
//        menu.locality.latitude = menuDto.locality.latitude
//        menu.locality.longitude = menuDto.locality.longitude
//        menu.locality.lowerLatitude = menuDto.locality.lowerLatitude
//        menu.locality.lowerLongitude = menuDto.locality.lowerLongitude
//        menu.locality.upperLatitude = menuDto.locality.upperLatitude
//        menu.locality.upperLongitude = menuDto.locality.upperLongitude
//
//        return menu
//    }
    
//    func persistCategories(ofMenuDto menuDto: MenuDto) {
//        do {
//            try CoreStore.perform(synchronous: { [unowned self] (transaction) in
//                let menu = transaction.fetchOne(
//                    From<MenuEntity>(),
//                    Where("serverId", isEqualTo: menuDto.menuID))!
//
//                self.persistCategories(categoryDtos: menuDto.categories, menu: menu, transaction: transaction)
//            })
//
//        } catch {
//            // todo: log error
//        }
//    }
//
//    func persistCategories(categoryDtos: [CategoryDto], menu: MenuEntity, transaction: BaseDataTransaction) {
//        if let categoryEntities = transaction.fetchAll(
//            From<MenuCategoryEntity>(),
//            Where("menu.serverId", isEqualTo: menu.serverId)) {
//
//            for categoryEntity in categoryEntities {
//                if categoryDtos.filter({$0.id == categoryEntity.serverId}).first == nil {
//                    transaction.delete(categoryEntity)// todo: TEST THIS CASE
//                }
//            }
//        }
//
//        for categoryDto in categoryDtos {
//            let categoryEntity = transaction.fetchOne(From<MenuCategoryEntity>(),
//                                                      Where("serverId", isEqualTo: categoryDto.id)) ??
//                transaction.create(Into<MenuCategoryEntity>())
//
//            categoryEntity.serverId = categoryDto.id
//            categoryEntity.title = categoryDto.name
////            categoryEntity.rank = categoryDto.rank
//            categoryEntity.imageUrl = categoryDto.photo.url
//            categoryEntity.imageSize = CGSize(width: CGFloat(categoryDto.photo.width),
//                                              height: CGFloat(categoryDto.photo.height))
//            categoryEntity.menu = menu
//        }
//    }
    
//    func persistRecommendations(productDtos: [ProductDto]) {
//        do {
//            try CoreStore.perform(synchronous: { [unowned self] (transaction) in
//                if let curRecommendedProducts = transaction.fetchAll(From<ProductEntity>(),
//                                                                     Where("isRecommended", isEqualTo: true)) {
//                    for product in curRecommendedProducts {
//                        if productDtos.filter({$0.id == product.serverId}).first == nil {
//                            transaction.edit(product)?.isRecommended = false
//                        }
//                    }
//                }
//
//                for productDto in productDtos {
//                    if let menuCategory = transaction.fetchOne(
//                        From<MenuCategoryEntity>(),
//                        Where("serverId", isEqualTo: productDto.categoryID)) {
//
//                        self.persistProduct(productDto: productDto,
//                                            menuCategory: menuCategory,
//                                            transaction: transaction,
//                                            isRecommended: true)
//                    }
//                }
//            })
//        } catch {
//            // todo: log error
//        }
//    }
    
//    func persistProduct(productDto: ProductDto, menuCategory: MenuCategoryEntity, transaction: BaseDataTransaction, isRecommended: Bool = false) {
//        let productEntity = transaction.fetchOne(From<ProductEntity>(), Where("serverId", isEqualTo: productDto.id)) ??
//            transaction.create(Into<ProductEntity>())
//
//        productEntity.serverId = productDto.id
//        productEntity.title = productDto.name
//        productEntity.subtitle = productDto.subheading
//        productEntity.imageUrl = productDto.photo.url
//        productEntity.imageSize = CGSize(width: CGFloat(productDto.photo.width),
//                                         height: CGFloat(productDto.photo.height))
//        productEntity.isRecommended = isRecommended
//        productEntity.menuCategory = menuCategory
//
//        for priceDto in productDto.pricing {
//            self.persistPrice(priceDto: priceDto,
//                              product: productEntity,
//                              transaction: transaction)
//        }
//    }
    
//    func persistPrice(priceDto: PriceDto, product: ProductEntity, transaction: BaseDataTransaction) {
//        let priceEntity = transaction.fetchOne(From<PriceEntity>(), Where("serverId", isEqualTo: priceDto.id)) ??
//            transaction.create(Into<PriceEntity>())
//
//        priceEntity.serverId = priceDto.id
//        priceEntity.value = priceDto.value
//        priceEntity.modifierName = priceDto.modifier
//        priceEntity.currencyLocale = priceDto.currencyLocale
//        priceEntity.product = product
//    }
}
