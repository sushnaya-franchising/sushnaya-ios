//
//  PopExt.swift
//  Food
//
//  Created by Igor Kurylenko on 3/28/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import UIKit
import pop
import QuartzCore

// more convinient way to create pop animations - xcode autocompletion, shows possible args
// and no need to remember kPOP constant names
extension POPSpringAnimation {
    
    static func viewScaleXY(toValue to: Point, fromValue from: Point? = nil,
                            bounciness: Float? = nil, velocity: Point? = nil) -> POPSpringAnimation {
        return POPSpringAnimationBuilder(forProperty: kPOPViewScaleXY)
            .setToValue(CGPoint.from(to)!.asNSValue)
            .setFromValue(CGPoint.from(from)?.asNSValue)
            .setVelocity(CGPoint.from(velocity)?.asNSValue)
            .setBounciness(bounciness?.asCGFloat)
            .create()
    }
    
    static func viewCenter(toValue to: Point, fromValue from: Point? = nil,
                           bounciness: Float? = nil, velocity: Point? = nil) -> POPSpringAnimation {
        return POPSpringAnimationBuilder(forProperty: kPOPViewCenter)
            .setToValue(CGPoint.from(to)!.asNSValue)
            .setFromValue(CGPoint.from(from)?.asNSValue)
            .setVelocity(CGPoint.from(velocity)?.asNSValue)
            .setBounciness(bounciness?.asCGFloat)
            .create()
    }
    
    static func layerShadowOffset(toValue to: Size, fromValue from: Size? = nil,
                                  bounciness: Float? = nil, velocity: Point? = nil) -> POPSpringAnimation {
        return POPSpringAnimationBuilder(forProperty: kPOPLayerShadowOffset)
            .setToValue(CGSize.from(to).asNSValue)
            .setFromValue(CGSize.from(from)?.asNSValue)
            .setVelocity(CGPoint.from(velocity)?.asNSValue)
            .setBounciness(bounciness?.asCGFloat)
            .create()
    }
    
    static func layerShadowRadius(toValue to: Float, formValue from: Float? = nil,
                                  bounciness: Float? = nil, velocity: Float? = nil) -> POPSpringAnimation {
        return POPSpringAnimationBuilder(forProperty: kPOPLayerShadowRadius)
            .setToValue(to.asNSNumber)
            .setFromValue(from?.asNSNumber)
            .setVelocity(velocity?.asNSNumber)
            .setBounciness(bounciness?.asCGFloat)
            .create()
    }
    
    static func layerShadowOpacity(toValue to: Float, fromValue from: Float? = nil,
                                   bounciness: Float? = nil, velocity: Float? = nil) -> POPSpringAnimation {
        return POPSpringAnimationBuilder(forProperty: kPOPLayerShadowOpacity)
            .setToValue(to.asNSNumber)
            .setFromValue(from?.asNSNumber)
            .setVelocity(velocity?.asNSNumber)
            .setBounciness(bounciness?.asCGFloat)
            .create()
    }
    
    static func viewAlpha(toValue to: Float, fromValue from: Float? = nil,
                          bounciness: Float? = nil, velocity: Float? = nil) -> POPSpringAnimation {
        return POPSpringAnimationBuilder(forProperty: kPOPViewAlpha)
            .setToValue(to.asNSNumber)
            .setFromValue(from?.asNSNumber)
            .setVelocity(velocity?.asNSNumber)
            .setBounciness(bounciness?.asCGFloat)
            .create()
    }
    
    static func layerPositionX(toValue to: Float, fromValue from: Float? = nil,
                               bounciness: Float? = nil, velocity: Float? = nil) -> POPSpringAnimation {
        return POPSpringAnimationBuilder(forProperty: kPOPLayerPositionX)
            .setToValue(to.asNSNumber)
            .setFromValue(from?.asNSNumber)
            .setVelocity(velocity?.asNSNumber)
            .setBounciness(bounciness?.asCGFloat)
            .create()
    }
    
    static func scrollViewContentOffset(toValue to: Point,
                                        bounciness: Float? = nil, velocity: Point? = nil) -> POPSpringAnimation {
        return POPSpringAnimationBuilder(forProperty: kPOPScrollViewContentOffset)
            .setToValue(CGPoint.from(to)!.asNSValue)
            .setVelocity(CGPoint.from(velocity)?.asNSValue)
            .setBounciness(bounciness?.asCGFloat)
            .create()
    }
    
    static func layerPositionY(toValue to: Float, fromValue from: Float? = nil,
                               bounciness: Float? = nil, velocity: Float? = nil) -> POPSpringAnimation {
        return POPSpringAnimationBuilder(forProperty: kPOPLayerPositionY)
            .setToValue(to.asNSNumber)
            .setFromValue(from?.asNSNumber)
            .setVelocity(velocity?.asNSNumber)
            .setBounciness(bounciness?.asCGFloat)
            .create()
    }
    
    static func layerPosition(toValue to: Point, fromValue from: Point? = nil,
                              bounciness: Float? = nil, velocity: Point? = nil) -> POPSpringAnimation {
        return POPSpringAnimationBuilder(forProperty: kPOPLayerPosition)
            .setToValue(CGPoint.from(to)!.asNSValue)
            .setFromValue(CGPoint.from(from)?.asNSValue)
            .setVelocity(CGPoint.from(velocity)?.asNSValue)
            .setBounciness(bounciness?.asCGFloat)
            .create()
    }
    
    static func viewBackground(toValue to: UIColor, fromValue from: UIColor? = nil) -> POPSpringAnimation {
        return POPSpringAnimationBuilder(forProperty: kPOPViewBackgroundColor)
            .setToValue(to)
            .setFromValue(from)                        
            .create()
    }
    
    class POPSpringAnimationBuilder {
        fileprivate var forProperty: String
        fileprivate var toValue: Any?
        fileprivate var fromValue: Any?
        fileprivate var bounciness: CGFloat?
        fileprivate var velocity: NSValue?
        
        init(forProperty: String) {
            self.forProperty = forProperty
        }
        
        func setToValue(_ toValue: Any?) -> POPSpringAnimationBuilder {
            self.toValue = toValue
            return self
        }
        
        func setFromValue(_ fromValue: Any?) -> POPSpringAnimationBuilder {
            self.fromValue = fromValue
            return self
        }
        
        func setBounciness(_ bounciness: CGFloat?) -> POPSpringAnimationBuilder {
            self.bounciness = bounciness
            return self
        }
        
        func setVelocity(_ velocity: NSValue?) -> POPSpringAnimationBuilder {
            self.velocity = velocity
            return self
        }
        
        func create() -> POPSpringAnimation {
            let animation = POPSpringAnimation(propertyNamed: forProperty)
            
            animation?.toValue = toValue
            
            if let fromValue = fromValue {
                animation?.fromValue = fromValue
            }
            
            if let velocity = velocity {
                animation?.velocity = velocity
            }
            
            if let bounciness = bounciness {
                animation?.springBounciness = bounciness
            }
            
            return animation!
        }
    }
    
}

extension POPBasicAnimation {
    
    static func viewCenter(toValue to: Point, fromValue from: Point? = nil,
                           duration: Float? = nil, timingFunction: String? = nil) -> POPBasicAnimation {
        return POPBasicAnimationBuilder(forProperty: kPOPViewCenter)
            .setToValue(CGPoint.from(to)!.asNSValue)
            .setFromValue(CGPoint.from(from)?.asNSValue)
            .setDuration(duration?.asCFTimeInterval)
            .setTimingFunction(timingFunction?.asCAMediaTimingFunction)
            .create()
    }
    
    static func viewAlpha(toValue to: Float, fromValue from: Float? = nil,
                          duration: Float? = nil, timingFunction: String? = nil) -> POPBasicAnimation {
        return POPBasicAnimationBuilder(forProperty: kPOPViewAlpha)
            .setToValue(to.asNSNumber)
            .setFromValue(from?.asNSNumber)
            .setDuration(duration?.asCFTimeInterval)
            .setTimingFunction(timingFunction?.asCAMediaTimingFunction)
            .create()
    }
    
    static func layerPositionY(toValue to: Float,
                               fromValue from: Float? = nil, duration: Float? = nil,
                               timingFunction: String? = nil) -> POPBasicAnimation {
        return POPBasicAnimationBuilder(forProperty: kPOPLayerPositionY)
            .setToValue(to.asNSNumber)
            .setFromValue(from?.asNSNumber)
            .setDuration(duration?.asCFTimeInterval)
            .setTimingFunction(timingFunction?.asCAMediaTimingFunction)
            .create()
    }
    
    static func layerPositionX(toValue to: Float,
                               fromValue from: Float? = nil, duration: Float? = nil,
                               timingFunction: String? = nil) -> POPBasicAnimation {
        return POPBasicAnimationBuilder(forProperty: kPOPLayerPositionX)
            .setToValue(to.asNSNumber)
            .setFromValue(from?.asNSNumber)
            .setDuration(duration?.asCFTimeInterval)
            .setTimingFunction(timingFunction?.asCAMediaTimingFunction)
            .create()
    }
    
    class POPBasicAnimationBuilder {
        fileprivate var forProperty: String
        fileprivate var toValue: NSValue?
        fileprivate var fromValue: NSValue?
        fileprivate var timingFunction: CAMediaTimingFunction?
        fileprivate var duration: CFTimeInterval?
        
        init(forProperty: String) {
            self.forProperty = forProperty
        }
        
        func setToValue(_ toValue: NSValue?) -> POPBasicAnimationBuilder {
            self.toValue = toValue
            return self
        }
        
        func setFromValue(_ fromValue: NSValue?) -> POPBasicAnimationBuilder {
            self.fromValue = fromValue
            return self
        }
        
        func setTimingFunction(_ timingFunction: CAMediaTimingFunction?) -> POPBasicAnimationBuilder {
            self.timingFunction = timingFunction
            return self
        }
        
        func setDuration(_ duration: CFTimeInterval?) -> POPBasicAnimationBuilder {
            self.duration = duration
            return self
        }
        
        func create() -> POPBasicAnimation {
            let animation = POPBasicAnimation(propertyNamed: forProperty)
            
            animation?.toValue = toValue
            
            if let fromValue = fromValue {
                animation?.fromValue = fromValue
            }
            
            if let timingFunction = timingFunction {
                animation?.timingFunction = timingFunction
            }
            
            if let duration = duration {
                animation?.duration = duration
            }
            
            return animation!
        }
    }
}

extension POPDecayAnimation {
    
    static func layerPositionY(_ velocity: Float? = nil) -> POPDecayAnimation {
        return POPDecayAnimationBuilder(forProperty: kPOPLayerPositionY)
            .setVelocity(velocity?.asNSNumber)
            .create()
    }
    
    class POPDecayAnimationBuilder {
        fileprivate var forProperty: String
        fileprivate var velocity: NSValue?
        
        init(forProperty: String) {
            self.forProperty = forProperty
        }
        
        func setVelocity(_ velocity: NSValue?) -> POPDecayAnimationBuilder {
            self.velocity = velocity
            return self
        }
        
        func create() -> POPDecayAnimation {
            let animation = POPDecayAnimation(propertyNamed: forProperty)
            
            if let velocity = velocity {
                animation?.velocity = velocity
            }
            
            return animation!
        }
    }
}

