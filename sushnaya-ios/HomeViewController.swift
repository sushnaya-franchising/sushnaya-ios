//
//  ViewController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/15/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import UIKit
import SwiftWebSocket
import CoreLocation
import PromiseKit

class HomeViewController: AppViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        ensureAPIChatIsOpened()
    }
    
    private func ensureAPIChatIsOpened() {
        if !app.isAPIChatOpened {
            let onNetworkActivity = Debouncer {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
            }.onCancel {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            onNetworkActivity.apply()
            
            firstly {
                return API.openAPIChat(authToken: app.userSession.authToken!)
            
            }.then { apiChat -> () in
                self.app.apiChat = apiChat
                
                apiChat.menu()// todo: request personal categories
            
            }.always {
                onNetworkActivity.cancel()
            
            }.catch { error in
                // todo: handle error
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
}
