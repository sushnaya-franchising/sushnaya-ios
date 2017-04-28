//
//  PaperButton.swift
//  Fama
//
//  Created by kurilenko igor on 2/6/16.
//  Copyright © 2016 igor kurilenko. All rights reserved.
//


import Foundation
import UIKit
import QuartzCore
import pop

@IBDesignable
open class PaperButton: UIButton {
    fileprivate let ScaleAnimationKey = "scaleAnimation"
    fileprivate let ShadowOffsetAnimationKey = "shadowOffsetAnimation"
    fileprivate let ShadowRadiusAnimationKey = "shadowRadiusAnimation"
    fileprivate let ShadowOpacityAnimationKey = "shadowOpacityAnimation"
    fileprivate let IconImpulseAnimationKey = "iconImpulseAnimation"
    
    static let ButtonScaleBounciness: Float = 15
    static let ButtonScaleVelocity: Point = (1, 1)
    static let IconImpulseBounciness: Float = 18
    static let IconImpulseVelocity:Point = (3, 3)
    
    static let InitialScale:Point = (1, 1)
    static let DefaultElevation = PaperElevation.z1
    
    // todo: use another property to change elevantion. currently elevation is being decreased if button is dragged.
    open override var isHighlighted:Bool {
        didSet {
            if isHighlighted != oldValue {
                isHighlighted ? didHighlight(): didHighlightOff()
            }
        }
    }
    
    @IBInspectable open var elevation: PaperElevation = PaperButton.DefaultElevation {
        didSet {
            updateShadow()
        }
    }
    
    @IBInspectable open var cornerRadius: Float = 2.0 {
        didSet {
            layer.cornerRadius = CGFloat(cornerRadius)
            
            updateShadow()
        }
    }
    
    @IBInspectable open var iconColor: UIColor! {
        didSet {
            updateIcon()
        }
    }
    
    @IBInspectable open var icon: UIImage! {
        didSet {
            updateIcon()
        }
    }
    
    fileprivate var iconImageView: UIImageView!
    
    fileprivate var curScale: Point = InitialScale {
        didSet {
            guard let animation = getOngoingAnimation(ScaleAnimationKey) else {
                return playNewAnimation(forAnimationKey: ScaleAnimationKey)
            }
            
            animation.toValue = CGPoint.from(curScale)!.asNSValue
        }
    }
    
    fileprivate var curShadowOffset: Size = PaperButton.DefaultElevation.getShadowOffset() {
        didSet {
            guard let animation = getOngoingAnimation(ShadowOffsetAnimationKey) else {
                return playNewAnimation(forAnimationKey: ShadowOffsetAnimationKey)
            }
            
            animation.toValue = CGSize.from(curShadowOffset).asNSValue
        }
    }
    
    fileprivate var curShadowRadius: Float = PaperButton.DefaultElevation.getShadowRadius() {
        didSet {
            guard let animation = getOngoingAnimation(ShadowRadiusAnimationKey) else {
                return playNewAnimation(forAnimationKey: ShadowRadiusAnimationKey)
            }
            
            animation.toValue = curShadowRadius.asNSNumber
        }
    }
    
    fileprivate var curShadowOpacity: Float = PaperButton.DefaultElevation.getShadowOpacity() {
        didSet {
            guard let animation = getOngoingAnimation(ShadowOpacityAnimationKey) else {
                return playNewAnimation(forAnimationKey: ShadowOpacityAnimationKey)
            }
            
            animation.toValue = curShadowOpacity.asNSNumber
        }
    }
    
    /**
     The function to compute an elevation level on touch down event.
     
     @param currentElevation The current elevation level of this button will be passed.
     */
    var highlightElevationStrategy: (_ currentElevation: PaperElevation) -> PaperElevation =
    PaperButton.DoubleUpHighlightElevetaionStrategy
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateShadow()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateShadow()
    }
    
    fileprivate func updateIcon() {
        guard let icon = icon else { return }
        
        if iconImageView == nil {
            iconImageView = createIconImageView(icon)
            addSubview(iconImageView)
        }
        
        if let color = iconColor {
            iconImageView.image = icon.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = color
            
        }else {
            iconImageView.image = icon
        }
        
        playNewAnimation(forAnimationKey: IconImpulseAnimationKey)
    }
    
    fileprivate func updateShadow() {
        let shadowOffset = CGSize.from(elevation.getShadowOffset())!
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = elevation.getShadowRadius().asCGFloat
        layer.shadowOpacity = elevation.getShadowOpacity()
        layer.shadowColor = elevation.getShadowColor().cgColor
        layer.shadowPath = UIBezierPath(
            roundedRect: CGRect(
                x: bounds.origin.x - shadowOffset.width,
                y: bounds.origin.y + shadowOffset.height,
                width: bounds.size.width + (2 * shadowOffset.width),
                height: bounds.size.height + shadowOffset.height),
            cornerRadius: layer.cornerRadius).cgPath
    }
    
    // todo: refactor
    open override func updateConstraints() {
        layoutIfNeeded()
        
        updateShadow()
        
        iconImageView?.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        
        super.updateConstraints()
    }
    
    fileprivate func getOngoingAnimation(_ animationKey: String) -> POPSpringAnimation? {
        var result:POPSpringAnimation?
        
        switch animationKey {
        case ScaleAnimationKey:
            result = pop_animation(forKey: animationKey) as? POPSpringAnimation
        case ShadowRadiusAnimationKey, ShadowOffsetAnimationKey, ShadowOpacityAnimationKey:
            result = layer.pop_animation(forKey: animationKey) as? POPSpringAnimation
        default: break
        }
        
        return result
    }
    
    fileprivate func playNewAnimation(forAnimationKey key: String) {
        switch key {
        case ScaleAnimationKey:
            pop_add(createScaleAnimation(toValue: curScale), forKey: key)
        case ShadowRadiusAnimationKey:
            layer.pop_add(createShadowRadiusAnimation(toValue: curShadowRadius), forKey: key)
        case ShadowOffsetAnimationKey:
            layer.pop_add(createShadowOffsetAnimation(toValue: curShadowOffset), forKey: key)
        case ShadowOpacityAnimationKey:
            layer.pop_add(createShadowOpacityAnimation(toValue: curShadowOpacity), forKey: key)
        case IconImpulseAnimationKey:
            iconImageView?.pop_add(createIconImpulseAnimation(), forKey: key)
        default: break
        }
    }
    
    fileprivate func createIconImageView(_ icon: UIImage) -> UIImageView {
        let result = UIImageView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        result.image = icon
        result.contentMode = .center
        
        return result
    }
    
    fileprivate func didHighlight() {
        let highlightElevation = highlightElevationStrategy(elevation)
        
        curScale = computeHighlightedStateScale(highlightElevation)
        curShadowOffset = highlightElevation.getShadowOffset()
        curShadowRadius = highlightElevation.getShadowRadius()
        curShadowOpacity = highlightElevation.getShadowOpacity()
    }
    
    fileprivate func computeHighlightedStateScale(_ touchDownElevation: PaperElevation) -> Point {
        let shadowRadiusDelta = touchDownElevation.getShadowRadius() - elevation.getShadowRadius()
        let scale = (Float(bounds.size.height) + shadowRadiusDelta * 2) / Float(bounds.size.height)
        
        return (scale, scale)
    }
    
    fileprivate func didHighlightOff(){
        curScale = PaperButton.InitialScale
        curShadowOffset = elevation.getShadowOffset()
        curShadowRadius = elevation.getShadowRadius()
        curShadowOpacity = elevation.getShadowOpacity()
    }
}

extension PaperButton {
    static let ZeroUpHighlightElevetaionStrategy:(PaperElevation) -> PaperElevation = { elevation in
        return elevation
    }
    
    static let SingleUpHighlightElevetaionStrategy:(PaperElevation) -> PaperElevation = { elevation in
        return elevation.getNextElevationLevel()
    }
    
    static let DoubleUpHighlightElevetaionStrategy:(PaperElevation) -> PaperElevation = { elevation in
        return elevation.getNextElevationLevel().getNextElevationLevel()
    }
    
    static let TripleUpHighlightElevetaionStrategy:(PaperElevation) -> PaperElevation = { elevation in
        return elevation.getNextElevationLevel()
            .getNextElevationLevel().getNextElevationLevel()
    }
    
    func createIconImpulseAnimation() -> POPSpringAnimation {
        let toValue: Point = (1,1)
        let fromValue: Point = (0.95, 0.95)
        let result = POPSpringAnimation.viewScaleXY(
            toValue: toValue,
            fromValue: fromValue,
            bounciness: PaperButton.IconImpulseBounciness,
            velocity: PaperButton.IconImpulseVelocity)
        
        return result
    }
    
    func createScaleAnimation(toValue to: Point) -> POPSpringAnimation {
        return POPSpringAnimation.viewScaleXY(
            toValue: to,
            bounciness: PaperButton.ButtonScaleBounciness,
            velocity: PaperButton.ButtonScaleVelocity)
    }
    
    func createShadowOffsetAnimation(toValue to: Size) -> POPSpringAnimation {
        return POPSpringAnimation.layerShadowOffset(
            toValue: to,
            bounciness: PaperButton.ButtonScaleBounciness,
            velocity: PaperButton.ButtonScaleVelocity)
    }
    
    func createShadowRadiusAnimation(toValue to: Float) -> POPSpringAnimation {
        return POPSpringAnimation.layerShadowRadius(
            toValue: to,
            bounciness: PaperButton.ButtonScaleBounciness,
            velocity: PaperButton.ButtonScaleVelocity.0)
    }
    
    func createShadowOpacityAnimation(toValue to: Float) -> POPSpringAnimation {
        return POPSpringAnimation.layerShadowOpacity(
            toValue: to,
            bounciness: PaperButton.ButtonScaleBounciness,
            velocity: PaperButton.ButtonScaleVelocity.0)
    }
}
