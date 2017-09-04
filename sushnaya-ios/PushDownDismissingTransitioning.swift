//
// Created by Igor Kurylenko on 4/25/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import pop

class PushDownDismissingTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard var toVC = transitionContext.viewController(forKey: .to) else { return }
        
        if toVC is EditAddressViewController {
            toVC.dismiss(animated: false, completion: nil)
            toVC = toVC.presentingViewController!
        }
        
        guard let toView = toVC.view else { return }

        toView.tintAdjustmentMode = .normal
        toView.isUserInteractionEnabled = true

        guard let fromView = transitionContext.viewController(forKey: .from)?.view else { return }

        let fromViewPositionAnimation = POPBasicAnimation(propertyNamed: kPOPLayerPositionY)
        fromViewPositionAnimation?.toValue = fromView.layer.position.y * 3

        let toViewPositionAnimation = POPBasicAnimation(propertyNamed: kPOPLayerPositionY)
        toViewPositionAnimation?.toValue = fromView.layer.position.y
        toViewPositionAnimation?.completionBlock = { _ in
            transitionContext.completeTransition(true)
        }

        fromView.layer.pop_add(fromViewPositionAnimation, forKey: "positionAnimation")
        toView.layer.pop_add(toViewPositionAnimation, forKey: "positionAnimation")
    }
}
