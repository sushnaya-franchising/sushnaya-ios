//
//  CGSizeExt.swift
//  Food
//
//  Created by Igor Kurylenko on 3/28/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import UIKit

typealias Size = (Float, Float)

extension CGSize {
    var asNSValue: NSValue {
        return NSValue(cgSize: self)
    }
    
    static func from(_ size: Size!) -> CGSize! {
        guard let s = size else { return nil }
        
        return CGSize(width: CGFloat(s.0), height: CGFloat(s.1))
    }
    
    func resized(_ maxSize: CGFloat) -> CGSize {
        var result = self
        
        if width > maxSize || height > maxSize {
            let ratio = width / height
            
            if width >= height {
                result.width = maxSize
                result.height = maxSize / ratio
            } else {
                result.height = maxSize
                result.width = ratio * maxSize
            }
        }
        
        return result
    }
    
    var hashValue: Int {
        var result = 1
        
        result = 31 &* result &+ width.hashValue
        result = 31 &* result &+ height.hashValue
        
        return result
    }
}

