//
// Created by Igor Kurylenko on 4/25/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import pop

class PushUpPresentingTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.viewController(forKey: .from)?.view else { return }
        fromView.tintAdjustmentMode = .dimmed
        fromView.isUserInteractionEnabled = false

        guard let toView = transitionContext.viewController(forKey: .to)?.view else { return }
        toView.tintAdjustmentMode = .normal
        toView.isUserInteractionEnabled = true
        toView.frame = CGRect(x: 0, y: 0,
                width: transitionContext.containerView.bounds.width,
                height: transitionContext.containerView.bounds.height)

        let p = CGPoint(x: transitionContext.containerView.center.x, y: transitionContext.containerView.center.y * 3)
        toView.center = p

        transitionContext.containerView.addSubview(toView)

        let toViewPositionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
        toViewPositionAnimation?.toValue = transitionContext.containerView.center.y
        toViewPositionAnimation?.springBounciness = 5
        toViewPositionAnimation?.completionBlock = { _ in
            transitionContext.completeTransition(true)
        }

        let fromViewPositionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
        fromViewPositionAnimation?.toValue = transitionContext.containerView.center.y - fromView.bounds.height
        fromViewPositionAnimation?.springBounciness = 5

        fromView.layer.pop_add(fromViewPositionAnimation, forKey: "positionAnimation")
        toView.layer.pop_add(toViewPositionAnimation, forKey: "positionAnimation")
    }
}
