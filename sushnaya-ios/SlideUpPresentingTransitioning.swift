//
//  PresentingAnimationController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/8/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import pop

class SlideUpPresentingTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    var applyAlpha:Bool
    
    convenience override init() {
        self.init(applyAlpha: true)
    }
    
    init(applyAlpha: Bool) {
        self.applyAlpha = applyAlpha
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.viewController(forKey: .from)?.view else { return }
        fromView.tintAdjustmentMode = .dimmed
        fromView.isUserInteractionEnabled = false
        
        guard let toView = transitionContext.viewController(forKey: .to)?.view else { return }
        toView.frame = CGRect(x: 0, y: 0,
                               width: transitionContext.containerView.bounds.width,
                               height: transitionContext.containerView.bounds.height)
        
        let p = CGPoint(x: transitionContext.containerView.center.x, y: transitionContext.containerView.center.y * 3)
        toView.center = p
        
        transitionContext.containerView.addSubview(toView)
        
        let positionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
        positionAnimation?.toValue = transitionContext.containerView.center.y
        positionAnimation?.springBounciness = 5
        positionAnimation?.completionBlock = { _ in
            transitionContext.completeTransition(true)
        }
        
        toView.layer.pop_add(positionAnimation, forKey: "positionAnimation")
        
        if applyAlpha {
            let fromViewAlphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
            fromViewAlphaAnimation?.toValue = 0.6
        
            fromView.pop_add(fromViewAlphaAnimation, forKey: "alphaAnimation")
        }
    }
}
