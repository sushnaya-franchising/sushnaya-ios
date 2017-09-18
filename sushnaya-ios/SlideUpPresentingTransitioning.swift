import Foundation

class SlideUpPresentingTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.viewController(forKey: .from)?.view,
            let toView = transitionContext.viewController(forKey: .to)?.view else { return }

        fromView.tintAdjustmentMode = .dimmed
        fromView.isUserInteractionEnabled = false
        
        let screenBounds = UIScreen.main.bounds
        let bottomLeftCorner = CGPoint(x: 0, y: screenBounds.height)
        let initialFrame = CGRect(origin: bottomLeftCorner, size: screenBounds.size)
        toView.frame = initialFrame
        
        let p = CGPoint(x: transitionContext.containerView.center.x, y: transitionContext.containerView.center.y * 3)
        toView.center = p
        
        transitionContext.containerView.addSubview(toView)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 2,
            options: .curveEaseInOut,
            animations: {
                toView.frame = CGRect(origin: CGPoint.zero, size: screenBounds.size)
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
    }
}
