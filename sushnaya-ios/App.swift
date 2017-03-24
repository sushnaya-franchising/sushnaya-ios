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


@UIApplicationMain
class App: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let userSession = UserSession()
    
    private let apiChat = APIChat()
    
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
        
        let onNetworkActivity = Debouncer {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
        }.onCancel {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
        }.apply()
        
        firstly {
            return apiChat.connect(authToken: userSession.authToken!)
                
        }.always {
            onNetworkActivity.cancel()
                    
        }.catch { error in
            // todo: handle error
        }
    }
    
    private func registerEventHandlers() {
        // todo: create event to show terms of use controller
        SwiftEventBus.onMainThread(self, name: TermsOfUseUpdatedEvent.name) { [weak self] (notification) in
            // todo: use url from event
            let controller = self!.storyboard.instantiateViewController(withIdentifier: "TermsOfUse")
            
            self?.window?.rootViewController?.present(controller, animated: true, completion: nil)
        }
        
        SwiftEventBus.onMainThread(self, name: AuthenticationEvent.name) { [weak self] (notification) in
            self?.userSession.authToken = (notification.object as! AuthenticationEvent).authToken
            
            self?.startAPIChat()
            
            self?.changeRootViewController(withIdentifier: "Entry")
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

