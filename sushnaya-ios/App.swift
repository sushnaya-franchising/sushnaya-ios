//
//  AppDelegate.swift
//  Food
//
//  Created by Igor Kurylenko on 3/27/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import SwiftEventBus
import SwiftWebSocket
import PaperFold
import FontAwesome_swift
import PromiseKit

@UIApplicationMain
class App: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var userSession = UserSession()

    private let apiChat = APIChat()

    private var apiChatRestartDelay = 1        
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupWindow()
        
        registerEventHandlers()

        YMKConfiguration.sharedInstance().apiKey = "eT8sMHf8HJ3h34nIeC5nzRCx2Ye6JOm9q-02lkLxX9BdERx9-itfjncZ2uWaI5~mdjMYweAA7FTHb44Z7VptmGlbzFKvVW3IZnM9TYBjjzg="

        // ASControlNode.setEnableHitTestDebug(true)
        
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

    private func createDefaultRootViewController() -> UIViewController {
        let rootTBC = MainController()
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.

        apiChat.disconnect()
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

        startAPIChat()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

        SwiftEventBus.unregister(self)
    }

    private func startAPIChat() {
        guard userSession.isLoggedIn else {
            return
        }

        print("Starting API chat...")

        let onNetworkActivity = debounce {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true

        }.onCancel {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

        }.apply()

        firstly {
            return apiChat.connect(authToken: userSession.authToken!)

        }.always {
            onNetworkActivity.cancel()

        }.catch { _ in
        }
    }

    private func restartAPIChat() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(apiChatRestartDelay), execute: self.startAPIChat)

        if apiChatRestartDelay < 60 {
            apiChatRestartDelay = apiChatRestartDelay << 1
        }
    }

    private func registerEventHandlers() {
        SwiftEventBus.onMainThread(self, name: TermsOfUseUpdatedEvent.name) { [unowned self] (notification) in
            // todo: use url from event
            let vc = TermsOfUseViewController()

            self.window?.rootViewController?.present(vc, animated: true, completion: nil)
        }

        SwiftEventBus.onMainThread(self, name: AuthenticationEvent.name) { [unowned self] (notification) in
            self.userSession.authToken = (notification.object as! AuthenticationEvent).authToken

            self.startAPIChat()

            let authenticatedVC = self.createDefaultRootViewController()
            // todo: open full side vc with categories and set tab bar invisible

            self.changeRootViewController(authenticatedVC)
        }

        SwiftEventBus.onMainThread(self, name: ChangeLocalityProposalEvent.name) { [unowned self] (notification) in
            let localities = (notification.object as! ChangeLocalityProposalEvent).localities

            func presentLocalitiesController() {
                let vc = LocalitiesViewController(localities: localities)

                self.window?.rootViewController?.present(vc, animated: true, completion: nil)
            }

            func getLocality(by location: CLLocation) -> Locality? {
                return localities.filter {
                    $0.isIncluded(location: location)
                }.first
            }

            CLLocationManager.promise().then { location -> () in
                if let locality = getLocality(by: location) {
                    ChangeLocalityEvent.fire(locality: locality)                    

                } else {
                    presentLocalitiesController()
                }

            }.catch { error in
                presentLocalitiesController()
            }
        }

        SwiftEventBus.onMainThread(self, name: APIChatErrorEvent.name) { notification in
            if let event = notification.object as? APIChatErrorEvent {
                switch event.cause {

                case WebSocketError.network(let description):
                    print("WebSocket error: \(description)")

                default:
                    print(event.cause)
                }
            }
        }

        SwiftEventBus.onMainThread(self, name: ConnectionDidOpenAPIChatEvent.name) { [unowned self] (notification) in
            print("API chat connected")
            self.apiChatRestartDelay = 1
        }

        SwiftEventBus.onMainThread(self, name: ConnectionDidCloseAPIChatEvent.name) { [unowned self] (notification) in
            self.restartAPIChat()
        }
    }

    func changeRootViewController(_ vc: UIViewController) {
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
}

extension App: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        (tabBarController as! MainController).setPaperFoldState(isFolded: true, animated: true)
    }
}
