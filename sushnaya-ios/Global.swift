//
// Created by Igor Kurylenko on 3/30/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import SwiftEventBus
import AsyncDisplayKit

typealias EventBus = SwiftEventBus

class HashValueUtil {
    static func hashValue<T: Hashable>(of: [T?]) -> Int {
        var result = 1
        
        for x in of {
            result = 31 &* result &+ (x?.hashValue ?? 0)
        }
        
        return result
    }
}

func ImageNodePrecompositedCornerModification(cornerRadius: CGFloat) -> ((UIImage) -> UIImage) {
    return { (image: UIImage) -> UIImage in
        let rect = CGRect(origin: CGPoint.zero, size: image.size)

        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)

        UIBezierPath.init(roundedRect: rect, cornerRadius: cornerRadius * UIScreen.main.scale).addClip()
        image.draw(in: rect)
        let modifiedImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return modifiedImage!
    }
}

func drawTabBarImage(frame: CGRect = CGRect(x: 0, y: 0, width: 375, height: 49)) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
    //// Color Declarations
    let backgroundColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.980)
    
    //// Rectangle Drawing
    let rectanglePath = UIBezierPath(rect: CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height))
    backgroundColor.setFill()
    rectanglePath.fill()
    
    let resultImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return resultImage
}
