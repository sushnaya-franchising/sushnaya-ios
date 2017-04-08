//
//  DismissingAnimationController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/8/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import pop

class CartDismissingAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.viewController(forKey: .to)?.view else { return }
        toView.tintAdjustmentMode = .normal
        toView.isUserInteractionEnabled = true
        
        guard let fromView = transitionContext.viewController(forKey: .from)?.view else { return }
        
        let closeAnimation = POPBasicAnimation(propertyNamed: kPOPLayerPositionY)
        closeAnimation?.toValue = fromView.layer.position.y * 3
        closeAnimation?.completionBlock = { _ in
            transitionContext.completeTransition(true)
        }
        
        let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        alphaAnimation?.toValue = 1
        
        toView.pop_add(alphaAnimation, forKey: "alphaAnimation")
        fromView.layer.pop_add(closeAnimation, forKey: "closeAnimation")
    }
}
