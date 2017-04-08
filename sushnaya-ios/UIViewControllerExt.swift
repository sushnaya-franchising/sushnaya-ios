//
//  UIViewControllerExt.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/23/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

extension UIViewController {
    var app: App {
        get {
            return UIApplication.shared.delegate as! App
        }
    }
}

