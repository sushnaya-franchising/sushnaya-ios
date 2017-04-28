//
// Created by Igor Kurylenko on 4/8/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import PaperFold
import UIKit

class MainController: ASTabBarController {

    static let NarrowSideControllerWidth = CGFloat(96)

    private lazy var paperFoldNCs: [PaperFoldNavigationController] = []

    private var cartButtonSetupStarted = false

    private var cartVC: CartViewController!
    
    private func createCartButtonNode(containerRect: CGRect) -> CartButton {
        let button = CartButton()
        let layout = button.layoutThatFits(ASSizeRange(min: CGSize.zero, max: containerRect.size))
        
        let size = layout.size
        let origin = CGPoint(x: containerRect.midX - 32/2, y: containerRect.midY - CGFloat(size.height / 2))
        button.frame = CGRect(origin: origin, size: size)
        
        button.addTarget(self, action: #selector(presentCartViewController), forControlEvents: .touchUpInside)
        
        return button
    }

    private func addCartButtonViewAsynchronously(containerRect: CGRect) {
        DispatchQueue.global().async {
            let cartButtonNode = self.createCartButtonNode(containerRect: containerRect)
            
            DispatchQueue.main.async {
                self.view.addSubview(cartButtonNode.view)
            }
        }
    }
    
    func presentCartViewController() {
        present(cartVC, animated: true, completion: nil)
    }
    
    func setPaperFoldState(isFolded: Bool, animated: Bool) {
        paperFoldNCs.forEach {
            $0.setPaperFoldState(isFolded: isFolded, animated: animated)
        }
    }

    func addChildViewController(_ childController: UIViewController, narrowSideController: UIViewController) {
        let narrowNC = PaperFoldNavigationController(rootViewController: childController)
        narrowNC.setLeftViewController(leftViewController: narrowSideController, width: MainController.NarrowSideControllerWidth)
        narrowNC.tabBarItem = childController.tabBarItem
        paperFoldNCs.append(narrowNC)

        self.addChildViewController(narrowNC)
        retakeScreenshotIfAsyncView(narrowSideController, navigationController: narrowNC)
    }

    private func retakeScreenshotIfAsyncView(_ vc: UIViewController, navigationController: PaperFoldNavigationController) {
        if var asyncView = (vc as? PaperFoldAsyncView) {
            asyncView.onViewUpdated = navigationController.retakeScreenShot
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cartVC = CartViewController()
        cartVC.transitioningDelegate = self
        cartVC.modalPresentationStyle = .custom
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // DIRTY HACK TO HIDE TAB BAR TOP BORDER
        if tabBar.subviews.count > tabBar.items!.count {
            tabBar.subviews[0].subviews[1].isHidden = true
        }

        if !cartButtonSetupStarted {
            let screenBounds = UIScreen.main.bounds
            let containerRect = CGRect(x: 0, y: screenBounds.height-49, width: screenBounds.width, height: 49)
            addCartButtonViewAsynchronously(containerRect: containerRect)
            cartButtonSetupStarted = true
        }
    }
}

extension MainController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CartPresentingAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CartDismissingAnimationController()
    }
}


