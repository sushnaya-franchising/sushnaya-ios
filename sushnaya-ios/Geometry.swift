//
//  Geometry.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/8/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

extension CGRect {
    func originForCenteredRectWithSize(size: CGSize) -> CGPoint {
        let x = midX - CGFloat(size.width / 2)
        let y = midY - CGFloat(size.height / 2)
        return CGPoint(x: x, y: y)
    }
}

extension CGSize {
    func sizeByInsetting(width: CGFloat, height: CGFloat) -> CGSize {
        var size = self
        size.width -= width
        size.height -= height
        return size
    }
}

extension CGPoint {
    func pointByOffsetting(x: CGFloat, y: CGFloat) -> CGPoint {
        var point = self
        point.x += x
        point.y += y
        return point
    }
}
