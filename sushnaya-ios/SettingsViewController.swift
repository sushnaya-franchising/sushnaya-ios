//
//  SettingsViewController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/24/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import UIKit


class SettingsViewController: AppViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
