//
//  PresentingAnimationController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/8/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import pop

class CartPresentingAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
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
                               height: transitionContext.containerView.bounds.height + 32)
        
        let p = CGPoint(x: transitionContext.containerView.center.x, y: transitionContext.containerView.center.y * 3)
        toView.center = p
        
        transitionContext.containerView.addSubview(toView)
        
        let positionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
        positionAnimation?.toValue = transitionContext.containerView.center.y
        positionAnimation?.springBounciness = 5
        positionAnimation?.completionBlock = { _ in
            transitionContext.completeTransition(true)
        }
        
        let fromViewAlphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        fromViewAlphaAnimation?.toValue = 0.6
        
        toView.layer.pop_add(positionAnimation, forKey: "positionAnimation")
        fromView.pop_add(fromViewAlphaAnimation, forKey: "alphaAnimation")
    }
}
