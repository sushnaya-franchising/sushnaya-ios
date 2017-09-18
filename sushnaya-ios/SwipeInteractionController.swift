import UIKit

class SwipeInteractionController: UIPercentDrivenInteractiveTransition {

    var interactionInProgress = false
    private var shouldCompleteTransition = false
    
    weak var destinationVC: UIViewController! {
        didSet {
            prepareGestureRecognizerInView(view: destinationVC.view)
        }
    }
    
    private func prepareGestureRecognizerInView(view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(gestureRecognizer:)))
        view.addGestureRecognizer(gesture)
    }
    
    func handleGesture(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let velocity = gestureRecognizer.velocity(in: destinationVC.view.superview)
        let transition = gestureRecognizer.translation(in: destinationVC.view.superview)
        
        var progress = (transition.y/destinationVC.view.bounds.height)
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))        
        
        switch gestureRecognizer.state {
        case .began:
            interactionInProgress = true
            destinationVC.dismiss(animated: true)
            
        case .changed:
            shouldCompleteTransition = progress > 0.2 || velocity.y > 200
            update(progress)
            
        case .cancelled:
            interactionInProgress = false
            cancel()
            
        default:
            interactionInProgress = false
            
            if !shouldCompleteTransition {
                cancel()
                
            } else {
                finish()
            }
        }
    }
    
}
