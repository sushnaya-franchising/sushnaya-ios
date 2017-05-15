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
        return UIApplication.shared.delegate as! App
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "ОК", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

