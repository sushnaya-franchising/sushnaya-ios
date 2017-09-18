import Foundation

final class SlidePresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    private let slideUpPresentingTransitioning = SlideUpPresentingTransitioning()
    private let slideDownDismissingTransitioning = SlideDownDismissingTransitioning()
    let interactionController = SwipeInteractionController()
    
    var dimmingViewAlpha: CGFloat
    
    init(dimmingViewAlpha: CGFloat = 0.3) {
        self.dimmingViewAlpha = dimmingViewAlpha
        super.init()
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SlidePresentationController(presentedViewController: presented, presenting: presenting, dimmingViewAlpha: dimmingViewAlpha)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return slideUpPresentingTransitioning
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return slideDownDismissingTransitioning
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController.interactionInProgress ? interactionController : nil
    }
}
