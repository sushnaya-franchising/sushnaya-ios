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


@UIApplicationMain
class App: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private(set) lazy var storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    private(set) lazy var userSession: UserSession = UserSession()
    
    var isAPIChatOpened: Bool {
        get{
            return apiChat != nil
        }
    }
    
    var apiChat: APIChat? {
        willSet {
            apiChat?.close()
        }
    }
    
    private var dispatcher: Dispatcher!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        
        dispatcher = Dispatcher(app: self)
        
        if !userSession.isLoggedIn {
            changeRootViewController(withIdentifier: "SignIn")
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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

