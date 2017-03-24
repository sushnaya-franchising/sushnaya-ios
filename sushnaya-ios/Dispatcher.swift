//
//  Dispatcher.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/23/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus

enum DispatcherEvent: String {
    case viewWillAppear
}

// todo: make singleton
class Dispatcher:NSObject {
    
    private unowned var app: App
    private weak var currentController: UIViewController?
    
    init(app: App) {
        self.app = app
        
        super.init()
        
        SwiftEventBus.onMainThread(self, name: DispatcherEvent.viewWillAppear.rawValue) { [weak self] (notification) in
            self?.currentController = notification.object as? UIViewController
        }
        
        SwiftEventBus.onMainThread(self, name: APIChatCommand.menu.rawValue) { [weak self] (notification) in
            guard self?.currentController is HomeViewController else {
                if let controller = self?.app.storyboard.instantiateViewController(withIdentifier: "Main") as? HomeViewController {
                    self?.currentController?.show(controller, sender: self?.currentController)
                }
                
                return
            }
        }
    }
}
