//
//  AppDelegate.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/15/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import PromiseKit
import SwiftEventBus
import SwiftWebSocket


@UIApplicationMain
class App: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let userSession = UserSession()
    
    private let apiChat = APIChat()
    
    private var restartDelay = 1
    
    var storyboard: UIStoryboard {
        get{
            return UIStoryboard(name: "Main", bundle: nil)
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        initRootViewController()
        
        registerEventHandlers()                
        
        return true
    }
    
    private func initRootViewController() {
        if !userSession.isLoggedIn {
            changeRootViewController(withIdentifier: "SignIn")
        }
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
        
        let onNetworkActivity = Debouncer {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(restartDelay), execute: self.startAPIChat)
        
        if restartDelay < 60 {
            restartDelay = restartDelay << 1
        }
    }
    
    private func registerEventHandlers() {
        SwiftEventBus.onMainThread(self, name: TermsOfUseUpdatedEvent.name) { [unowned self] (notification) in
            // todo: use url from event
            let controller = self.storyboard.instantiateViewController(withIdentifier: "TermsOfUse")
            
            self.window?.rootViewController?.present(controller, animated: true, completion: nil)
        }
        
        SwiftEventBus.onMainThread(self, name: AuthenticationEvent.name) { [unowned self] (notification) in
            self.userSession.authToken = (notification.object as! AuthenticationEvent).authToken
            
            self.startAPIChat()
            
            self.changeRootViewController(withIdentifier: "Entry")
        }
        
        SwiftEventBus.onMainThread(self, name: ChangeLocalityProposalEvent.name) { [unowned self] (notification) in
            let localities = (notification.object as! ChangeLocalityProposalEvent).localities
            
            func presentLocalitiesController(){
                let controller = self.storyboard.instantiateViewController(withIdentifier: "Localities") as! LocalitiesViewController
                controller.localities = localities
                
                self.window?.rootViewController?.present(controller, animated: true, completion: nil)
            }
            
            func getLocality(by location: CLLocation) -> Locality? {
                return localities.filter{ $0.isIncluded(location: location) }.first
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
                    print("Websocket error: \(description)")
                
                default:
                    print(event.cause)
                }
            }
        }
        
        SwiftEventBus.onMainThread(self, name: ConnectionDidOpenAPIChatEvent.name) { [unowned self] (notification) in
            print("API chat connected")
            self.restartDelay = 1
        }
        
        SwiftEventBus.onMainThread(self, name: ConnectionDidCloseAPIChatEvent.name) { [unowned self] (notification) in
            self.restartAPIChat()
        }
    }
    
    func changeRootViewController(withIdentifier identifier:String!) {
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        
        let snapshot:UIView = (self.window?.snapshotView(afterScreenUpdates: true))!
        controller.view.addSubview(snapshot);
        
        self.window?.rootViewController = controller;
        
        UIView.animate(withDuration: 0.3, animations: {() in
            snapshot.layer.opacity = 0;
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
        }, completion: {
            (value: Bool) in
            snapshot.removeFromSuperview();
        });
    }
}

