import UIKit
import AsyncDisplayKit
import PaperFold
import FontAwesome_swift
import PromiseKit
import Alamofire
import CoreStore


@UIApplicationMain
class App: UIResponder, UIApplicationDelegate {

    static let brandName = "Сушная" // todo: move to settings

    var window: UIWindow?

    let cart = Cart()
    let core: Core = Core.Singleton

    private let foodServiceWebsocket = FoodServiceWebSocket()

    private var restartWebsocketConnectionDelay = 1

    var isWebsocketConnected: Bool {
        return foodServiceWebsocket.isConnected
    }

    var isMenuSelected: Bool {
        return selectedMenu != nil
    }
    
    var selectedMenu: MenuEntity? {
        return core.settings.object?.selectedMenu
    }

    var authToken: String? {
        return core.settings.object?.authToken
    }

    var isLoggedIn: Bool {
        return core.settings.object?.authToken != nil
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        registerEventHandlers()
        configureYandexMapKit()
        setupWindow()

        return true
    }

    private func configureYandexMapKit() {
        YMKConfiguration.sharedInstance().apiKey = "eT8sMHf8HJ3h34nIeC5nzRCx2Ye6JOm9q-02lkLxX9BdERx9-itfjncZ2uWaI5~mdjMYweAA7FTHb44Z7VptmGlbzFKvVW3IZnM9TYBjjzg="
    }

    private func setupWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.backgroundColor = UIColor.black
        window.rootViewController = createRootViewController()
        window.makeKeyAndVisible()
    }

    private func createRootViewController() -> UIViewController {
        return isLoggedIn ? createDefaultRootViewController() :
                createSignInRootViewController()
    }

    private func createSignInRootViewController() -> UIViewController {
        let signInVC = SignInViewController()

        return ASNavigationController(rootViewController: signInVC)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.

        foodServiceWebsocket.disconnect()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        if let authToken = authToken {
            OpenConnectionEvent.fire(authToken: authToken)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

        EventBus.unregister(self)
    }

    private func connectWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(self.restartWebsocketConnectionDelay), execute: {
            OpenConnectionEvent.fire(authToken: self.authToken!)
        })

        if self.restartWebsocketConnectionDelay < 60 {
            self.restartWebsocketConnectionDelay = self.restartWebsocketConnectionDelay << 1
        }
    }

    private func registerEventHandlers() {

        // MARK: Connection events

        EventBus.onMainThread(self, name: OpenConnectionEvent.name) { [unowned self] notification in
            let authToken = (notification.object as! OpenConnectionEvent).authToken

            self.foodServiceWebsocket.connect(authToken: authToken)
        }

        EventBus.onMainThread(self, name: DidOpenConnectionEvent.name) { [unowned self] (notification) in
            print("Websocket connected")

            self.restartWebsocketConnectionDelay = 1
        }

        EventBus.onMainThread(self, name: DidCloseConnectionEvent.name) { [unowned self] (notification) in
            print("Did close connection")

            self.connectWithDelay()
        }

        EventBus.onMainThread(self, name: DidCloseConnectionWithErrorEvent.name) { notification in
            let cause = (notification.object as! DidCloseConnectionWithErrorEvent).cause

            print("Websocket connection error: \(cause)")

            self.connectWithDelay()
        }

        // MARK: Authentication events

        EventBus.onMainThread(self, name: RequestSMSWithVerificationCodeEvent.name) { notification in // todo: move phonenumber vc
            let phoneNumber = (notification.object as! RequestSMSWithVerificationCodeEvent).phoneNumber

            FoodServiceAuth.requestSMSWithVerificationCode(phoneNumber: phoneNumber)
        }

        EventBus.onMainThread(self, name: RequestAuthenticationTokenEvent.name) { notification in // todo: move to code vc
            let event = (notification.object as! RequestAuthenticationTokenEvent)
            let phoneNumber = event.phoneNumber
            let code = event.code

            FoodServiceAuth.requestAuthToken(phoneNumber: phoneNumber, code: code)
        }

        EventBus.onMainThread(self, name: DidRequestAuthenticationTokenEvent.name) { [unowned self] (notification) in
            let authToken = (notification.object as! DidRequestAuthenticationTokenEvent).authToken
            self.core.persistAuthToken(authToken)
            
            OpenConnectionEvent.fire(authToken: authToken)
            
            let defaultVC = self.createDefaultRootViewController()
            self.changeRootViewController(defaultVC)
        }

        // MARK: Terms events

        EventBus.onMainThread(self, name: DidUpdateTermsOfUseServerEvent.name) { [unowned self] (notification) in
            // todo: use url from event
            let vc = TermsOfUseViewController()

            self.window?.rootViewController?.present(vc, animated: true, completion: nil)
        }

        // MARK: Menu events        

        EventBus.onMainThread(self, name: DidSyncMenusEvent.name) { [unowned self] notification in
            self.ensureMenuSelected()
        }

        // MARK: Category events

        // MARK: Product events

    }
}

extension App: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        (tabBarController as! MainViewController).setPaperFoldState(isFolded: true, animated: true)

        if tabBarController.selectedIndex == 0 {
            DidSelectRecommendationsEvent.fire()
        }
    }
}

extension App {
    fileprivate func ensureMenuSelected() {
        guard !self.isMenuSelected else { return }
        
        guard (CoreStore.fetchCount(From<MenuEntity>()) ?? 0) > 0 else {
            // todo: present shop is closed vc
            return
        }
        
        func presentSelectMenuViewController() {
            self.window?.rootViewController?.present(SelectMenuViewController(), animated: true)
        }
        
        func selectMenu(by location: CLLocation) -> Bool {
            guard let menu = self.core.fetchMenu(by: location) else { return false }
            
            FoodServiceRest.requestSelectMenu(menuId: menu.serverId, authToken: authToken!)
            
            return true
        }
        
        CLLocationManager.promise().then { location -> () in
            if !selectMenu(by: location) {
                presentSelectMenuViewController()
            }
        }.catch { error in
            presentSelectMenuViewController()
        }
    }
    
    fileprivate func changeRootViewController(_ vc: UIViewController) {
        let snapshot: UIView = (self.window?.snapshotView(afterScreenUpdates: true))!
        vc.view.addSubview(snapshot)

        self.window?.rootViewController = vc;

        UIView.animate(withDuration: 0.3, animations: { () in
            snapshot.layer.opacity = 0;
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);

        }, completion: { (value: Bool) in
            snapshot.removeFromSuperview();
        });
    }

    fileprivate func createDefaultRootViewController() -> UIViewController {
        let rootTBC = MainViewController()
        rootTBC.delegate = self
        rootTBC.tabBar.unselectedItemTintColor = PaperColor.Gray
        rootTBC.tabBar.tintColor = PaperColor.Gray800
        rootTBC.tabBar.itemWidth = 39
        rootTBC.tabBar.itemPositioning = .centered
        rootTBC.tabBar.itemSpacing = UIScreen.main.bounds.width / 2
        rootTBC.tabBar.backgroundImage = drawTabBarImage()

        let homeNC = ASNavigationController(rootViewController: ProductsViewController())
        homeNC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)

        let logoImage = UIImage(named: "logo")!.withRenderingMode(.alwaysOriginal)
        let logoImageGrayScale = logoImage.convertToGrayScale().tranlucentWithAlpha(alpha: 0.5).withRenderingMode(.alwaysOriginal)

        homeNC.tabBarItem.image = logoImageGrayScale
        homeNC.tabBarItem.selectedImage = logoImage

        EventBus.onMainThread(self, name: DidSelectRecommendationsEvent.name) { _ in
            homeNC.tabBarItem.selectedImage = logoImage
        }

        EventBus.onMainThread(self, name: DidSelectCategoryEvent.name) { _ in
            homeNC.tabBarItem.selectedImage = logoImageGrayScale

            rootTBC.setPaperFoldState(isFolded: true, animated: true)
        }

        let settingsNC = ASNavigationController(rootViewController: SettingsViewController())
        settingsNC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        settingsNC.tabBarItem.image = UIImage.fontAwesomeIcon(name: .ellipsisH, textColor: PaperColor.Gray400, size: CGSize(width: 32, height: 32))

        rootTBC.addChildViewController(homeNC, narrowSideController: CategoriesViewController())
        rootTBC.addChildViewController(settingsNC)

        return rootTBC
    }
}
