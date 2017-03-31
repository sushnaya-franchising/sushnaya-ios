//
//  UIColorExt.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/16/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import UIKit

extension UIColor {
    class func fromUInt(_ value: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

