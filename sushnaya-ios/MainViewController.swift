import Foundation
import AsyncDisplayKit
import PaperFold
import UIKit

class MainViewController: ASTabBarController {

    static let NarrowSideControllerWidth = CGFloat(96)

    private lazy var paperFoldNCs: [PaperFoldNavigationController] = []

    private var cartButtonSetupStarted = false

    private var cartVC: CartViewController!
    
    private let presentationManager = SlidePresentationManager()
    
    private func addCartButtonViewAsynchronously(containerRect: CGRect) {
        DispatchQueue.global().async { [unowned self] _ in
            let cartButtonNode = self.createCartButtonNode(containerRect: containerRect)
            
            DispatchQueue.main.async { [unowned self] _ in
                self.view.addSubview(cartButtonNode.view)
            }
        }
    }
    
    private func createCartButtonNode(containerRect: CGRect) -> CartButton {
        let button = CartButton()
        let layout = button.layoutThatFits(ASSizeRange(min: CGSize.zero, max: containerRect.size))
        let size = layout.size
        let origin = CGPoint(x: containerRect.midX - 32/2, y: containerRect.midY - CGFloat(size.height / 2))
        button.frame = CGRect(origin: origin, size: size)
        
        button.addTarget(self, action: #selector(presentCartViewController), forControlEvents: .touchUpInside)
        
        return button
    }
    
    func presentCartViewController() {
        present(cartVC, animated: true)
    }
    
    func setPaperFoldState(isFolded: Bool, animated: Bool) {
        paperFoldNCs.forEach {
            $0.setPaperFoldState(isFolded: isFolded, animated: animated)
        }
    }

    func addChildViewController(_ childController: UIViewController, narrowSideController: UIViewController) {
        let narrowNC = PaperFoldNavigationController(rootViewController: childController)
        narrowNC.setLeftViewController(leftViewController: narrowSideController, width: MainViewController.NarrowSideControllerWidth)
        narrowNC.tabBarItem = childController.tabBarItem
        paperFoldNCs.append(narrowNC)

        self.addChildViewController(narrowNC)
        retakeScreenshotIfAsyncView(narrowSideController, navigationController: narrowNC)
    }

    private func retakeScreenshotIfAsyncView(_ vc: UIViewController, navigationController: PaperFoldNavigationController) {
        if let asyncView = (vc as? PaperFoldAsyncView) {
            navigationController.onPaperFoldViewDidOffset = {
                asyncView.stopAnimations?()
            }
            asyncView.onPaperFoldViewUpdated = navigationController.retakeScreenShot
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cartVC = CartViewController()
        cartVC.transitioningDelegate = presentationManager
        cartVC.modalPresentationStyle = .custom
        
        presentationManager.interactionController.destinationVC = cartVC
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // DIRTY HACK TO HIDE TAB BAR TOP BORDER
        if tabBar.subviews.count > tabBar.items!.count {
            tabBar.subviews[0].subviews[1].isHidden = true
        }

        if !cartButtonSetupStarted {
            let screenBounds = UIScreen.main.bounds
            let containerRect = CGRect(x: 0, y: screenBounds.height - 49, width: screenBounds.width, height: 49)
            addCartButtonViewAsynchronously(containerRect: containerRect)
            cartButtonSetupStarted = true
        }
    }
}

