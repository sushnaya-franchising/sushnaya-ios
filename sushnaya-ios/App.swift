import UIKit
import AsyncDisplayKit
import PaperFold
import FontAwesome_swift
import PromiseKit
import Alamofire
import CoreStore


@UIApplicationMain
class App: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var userSession = UserSession()
    
    private let foodServiceWebsocket = {
        return FoodServiceWebSocket()
    }()

    private let networkActivityIndicatorManager = NetworkActivityIndicatorManager.sharedInstance // todo: refactor
    
    private var restartWebsocketConnectionDelay = 1
    
    var isWebsocketConnected: Bool {
        return foodServiceWebsocket.isConnected
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        registerEventHandlers()

        YMKConfiguration.sharedInstance().apiKey = "eT8sMHf8HJ3h34nIeC5nzRCx2Ye6JOm9q-02lkLxX9BdERx9-itfjncZ2uWaI5~mdjMYweAA7FTHb44Z7VptmGlbzFKvVW3IZnM9TYBjjzg="
        
        CoreStore.defaultStack = DataStack(xcodeModelName: "Appnbot")
        
        do {
            try CoreStore.addStorageAndWait(SQLiteStore(fileName: "Appnbot.sqlite"))
        } catch {
            // todo: report fatal error
        }
        
        setupWindow()
        
        return true
    }

    private func setupWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.backgroundColor = UIColor.black
        window.rootViewController = createRootViewController()
        window.makeKeyAndVisible()
    }

    private func createRootViewController() -> UIViewController {
        return userSession.isLoggedIn ? createDefaultRootViewController() :
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
        
        if let authToken = userSession.settings.authToken {
            OpenConnectionEvent.fire(authToken: authToken)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

        EventBus.unregister(self)
    }
    
    private func connectWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(self.restartWebsocketConnectionDelay), execute: {
            OpenConnectionEvent.fire(authToken: self.userSession.settings.authToken!)
        })
        
        if self.restartWebsocketConnectionDelay < 60 {
            self.restartWebsocketConnectionDelay = self.restartWebsocketConnectionDelay << 1
        }
    }

    private func registerEventHandlers() {
        EventBus.onMainThread(self, name: OpenConnectionEvent.name) { [unowned self] notification in
            let authToken = (notification.object as! OpenConnectionEvent).authToken
                
            self.foodServiceWebsocket.connect(authToken: authToken)
        }
        
        EventBus.onMainThread(self, name: DidUpdateTermsOfUseServerEvent.name) { [unowned self] (notification) in
            // todo: use url from event
            let vc = TermsOfUseViewController()

            self.window?.rootViewController?.present(vc, animated: true, completion: nil)
        }

        EventBus.onMainThread(self, name: DidRequestAuthenticationTokenEvent.name) { [unowned self] (notification) in
            let authToken = (notification.object as! DidRequestAuthenticationTokenEvent).authToken

            do {
                try CoreStore.perform(synchronous: { [unowned self] (transaction) in
                    if let settings = transaction.edit(self.userSession.settings) {
                        settings.authToken = authToken
                    }
                })
            
                OpenConnectionEvent.fire(authToken: authToken)

                let authenticatedVC = self.createDefaultRootViewController()

                self.changeRootViewController(authenticatedVC)
            } catch {
                // todo: reveal error in appropriate vc
            }
        }

        EventBus.onMainThread(self, name: SelectMenuServerEvent.name) { [unowned self] (notification) in
            let menus = (notification.object as! SelectMenuServerEvent).menus

            func presentLocalitiesController() {
                let vc = MenusViewController(menus: menus)

                self.window?.rootViewController?.present(vc, animated: true, completion: nil)
            }

            func getMenu(by location: CLLocation) -> MenuDto? {
                return menus.filter {
                    $0.locality.includes(coordinate: location.coordinate) // todo: get most inner locality
                }.first
            }
            
            CLLocationManager.promise().then { location -> () in
                if let menuDto = getMenu(by: location) {
                    DidSelectMenuEvent.fire(menuDto: menuDto)

                } else {
                    presentLocalitiesController()
                }

            }.catch { error in
                presentLocalitiesController()
            }
        }

        EventBus.onMainThread(self, name: DidOpenConnectionEvent.name) { [unowned self] (notification) in
            print("API chat connected")
            self.restartWebsocketConnectionDelay = 1
        }

        EventBus.onMainThread(self, name: DidCloseConnectionEvent.name) { [unowned self] (notification) in
            print("Did close connection")
            
            self.connectWithDelay()
        }
        
        EventBus.onMainThread(self, name: DidCloseConnectionWithErrorEvent.name) { notification in
            let cause = (notification.object as! DidCloseConnectionWithErrorEvent).cause
            
            print("Websocket connection error: \(cause.localizedDescription)")
            
            self.connectWithDelay()
        }
        
        EventBus.onMainThread(self, name: RequestSMSWithVerificationCodeEvent.name) { notification in
            let phoneNumber = (notification.object as! RequestSMSWithVerificationCodeEvent).phoneNumber
            
            FoodServiceAuth.requestSMSWithVerificationCode(phoneNumber: phoneNumber)
        }
        
        EventBus.onMainThread(self, name: RequestAuthenticationTokenEvent.name) { notification in
            let event = (notification.object as! RequestAuthenticationTokenEvent)
            let phoneNumber = event.phoneNumber
            let code = event.code
            
            FoodServiceAuth.requestAuthToken(phoneNumber: phoneNumber, code: code)
        }
        
        EventBus.onMainThread(self, name: CategoriesServerEvent.name) { notification in
            let categories = (notification.object as! CategoriesServerEvent).categories
            
            
            
            do {
                try CoreStore.perform(synchronous: { [unowned self] (transaction) in
                    
                    for categoryDto in categories {
                        
                        print(categoryDto.name)
//                        transaction.fetchOne(From<MenuCategory>, Where("title", isEqualTo: categoryDto.name))
                    }
                    
//                    let menu = transaction.edit(self.menu) ?? transaction.create(Into<Menu>())
//                    menu.locality = transaction.edit(menu.locality) ?? transaction.create(Into<Locality>())
//                    
//                    menu.serverId = NSNumber.init(value: menuDto.menuID)
//                    menu.locality.name = menuDto.locality.name
//                    menu.locality.descr = menuDto.locality.descr
//                    menu.locality.fiasId = menuDto.locality.fiasID
//                    menu.locality.latitude = menuDto.locality.latitude
//                    menu.locality.longitude = menuDto.locality.longitude
//                    menu.locality.lowerLatitude = menuDto.locality.lowerLatitude
//                    menu.locality.lowerLongitude = menuDto.locality.lowerLongitude
//                    menu.locality.upperLatitude = menuDto.locality.upperLatitude
//                    menu.locality.upperLongitude = menuDto.locality.upperLongitude
                })
            } catch {
//                 todo: log error
            }
            
            print("Categories received")
        }
        
        EventBus.onMainThread(self, name: RecommendationsServerEvent.name) { notification in
            let products = (notification.object as! RecommendationsServerEvent).products
            
            print("Recommendations received")
        }
    }
}

extension App: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        (tabBarController as! MainViewController).setPaperFoldState(isFolded: true, animated: true)
    }
}

extension App {
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
        rootTBC.tabBar.itemSpacing = UIScreen.main.bounds.width/2
        rootTBC.tabBar.backgroundImage = drawTabBarImage()
        
        let homeNC = ASNavigationController(rootViewController: HomeViewController())
        homeNC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        let image = UIImage(named: "logo")!
        homeNC.tabBarItem.image = image.convertToGrayScale().tranlucentWithAlpha(alpha: 0.5).withRenderingMode(.alwaysOriginal)
        homeNC.tabBarItem.selectedImage = image.withRenderingMode(.alwaysOriginal)
        
        let settingsNC = ASNavigationController(rootViewController: SettingsViewController())
        settingsNC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        settingsNC.tabBarItem.image = UIImage.fontAwesomeIcon(name: .ellipsisH, textColor: PaperColor.Gray400, size: CGSize(width: 32, height: 32))
        
        rootTBC.addChildViewController(homeNC, narrowSideController: FiltersViewController())
        rootTBC.addChildViewController(settingsNC)
        
        return rootTBC
    }
}
