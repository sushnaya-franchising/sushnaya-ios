//
//  CGPoint+Fama.swift
//  Fama
//
//  Created by kurilenko igor on 2/4/16.
//  Copyright © 2016 igor kurilenko. All rights reserved.
//

import UIKit

typealias Point = (Float, Float)

extension CGPoint {
    var asNSValue: NSValue {
        return NSValue(cgPoint: self)
    }
    
    var asPoint: Point {
        return (Float(self.x), Float(self.y))
    }
    
    func copy(x: CGFloat? = nil, y: CGFloat? = nil) -> CGPoint {
        var result = self
        
        result.x = x ?? result.x
        result.y = y ?? result.y
        
        return result
    }
    
    static func from(_ point: Point?) -> CGPoint? {
        guard let o = point else { return nil }
        
        return CGPoint(x: CGFloat(o.0), y: CGFloat(o.1))
    }
}
