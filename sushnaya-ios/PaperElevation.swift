//
//  PaperElevation.swift
//  Fama
//
//  Created by kurilenko igor on 2/6/16.
//  Copyright © 2016 igor kurilenko. All rights reserved.
//

import UIKit

struct ShadowConfig {
    var opacity: Float
    var offset: Size
    var radius: Float
    var color: UIColor
}

public enum PaperElevation {
    case z0, z1, z2, z3, z4, z5
    
    static let ShadowConfigByElevation = [
        z0: ShadowConfig(opacity: 0, offset: Size(0, 0), radius: 0, color: UIColor(white: 0, alpha: 0.43)),
        z1: ShadowConfig(opacity: 1, offset: Size(0, 0.5), radius: 1, color: UIColor(white: 0, alpha: 0.43)),
        z2: ShadowConfig(opacity: 1, offset: Size(0, 1.5), radius: 2, color: UIColor(white: 0, alpha: 0.42)),
        z3: ShadowConfig(opacity: 1, offset: Size(0, 2.5), radius: 3, color: UIColor(white: 0, alpha: 0.41)),
        z4: ShadowConfig(opacity: 1, offset: Size(0, 3.5), radius: 4, color: UIColor(white: 0, alpha: 0.40)),
        z5: ShadowConfig(opacity: 1, offset: Size(0, 4.5), radius: 5, color: UIColor(white: 0, alpha: 0.39))
    ]
    
    func getShadowConfig() -> ShadowConfig {
        return PaperElevation.ShadowConfigByElevation[self]!
    }
    
    func getShadowOpacity() -> Float {
        return getShadowConfig().opacity
    }
    
    func getShadowOffset() -> Size {
        return getShadowConfig().offset
    }
    
    func getShadowRadius() -> Float {
        return getShadowConfig().radius
    }
    
    func getShadowColor() -> UIColor {
        return getShadowConfig().color
    }
    
    func getNextElevationLevel() -> PaperElevation {
        switch self {
        case .z0:
            return .z1
        case .z1:
            return .z2
        case .z2:
            return .z3
        case .z3:
            return .z4
        case .z4:
            return .z5
        default:
            return .z5
        }
    }
    
    func setupShadow(forLayer layer: CALayer?) {
        layer?.shadowColor = self.getShadowColor().cgColor
        layer?.shadowOffset =  CGSize.from(self.getShadowOffset())
        layer?.shadowOpacity = self.getShadowOpacity()
        layer?.shadowRadius = self.getShadowRadius().asCGFloat
    }
}
