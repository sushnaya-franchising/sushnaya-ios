//
//  CartViewController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/7/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class CartViewController: ASViewController<ASDisplayNode> {
    
    fileprivate var cartNode: CartNode!
    fileprivate var addressVC: AddressViewController!
    fileprivate var orderVC: OrderViewController!
    
    var cart: Cart {
        return app.userSession.cart
    }
    
    convenience init() {
        self.init(node: ASDisplayNode())
        
        setupCartNode()
        
        self.node.automaticallyManagesSubnodes = true
        self.node.layoutSpecBlock = { [unowned self] _ in
            return ASWrapperLayoutSpec(layoutElement: self.cartNode)
        }
        
        EventBus.onMainThread(self, name: DidRemoveFromCartEvent.name) { [unowned self] (notification) in
            if self.cart.isEmpty {
                self.dismiss(animated: true, completion: nil)
            }
        }        
    }
    
    private func setupCartNode() {
        cartNode = CartNode(cart: cart)
        cartNode.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cartNode.setNeedsLayout()
        cartNode.cartContentNode.setNeedsLayout()
        cartNode.cartContentNode.toolBarNode.setNeedsLayout()
        cartNode.cartContentNode.cartItemsTableNode.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        cartNode.cartContentNode.bindEventHandlers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cartNode.cartContentNode.unbindEventHandler()
    }
    
    fileprivate func showAddressViewController() {
        if addressVC == nil {
            addressVC = AddressViewController()
            addressVC.delegate = self
            addressVC.transitioningDelegate = self
            addressVC.modalPresentationStyle = .custom
        }
        
        show(addressVC, sender: self)
    }
    
    fileprivate func showOrderViewController() {
        if orderVC == nil {
            orderVC = OrderViewController()
            orderVC.transitioningDelegate = self
            orderVC.modalPresentationStyle = .custom
        }
        
        show(orderVC, sender: self)
    }
}

extension CartViewController: CartNodeDelegate {
    func cartNodeDidTouchUpInsideCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }

    func cartNodeDidTouchUpInsideOrderWithDeliveryButton() {
        if (app.userSession.settings.addresses?.isEmpty ?? true) {
            showAddressViewController()
        
        } else {
            showOrderViewController()
        }
    }
}

extension CartViewController: AddressViewControllerDelegate {
    func addressViewController(_ vc: AddressViewController, didSubmitAddress address: Address) {
        self.app.userSession.settings.addresses = [address] // todo: persists address and sync server
        showOrderViewController()
    }
}

extension CartViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OrderPresentingAnimationController()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OrderDismissingAnimationController()
    }
}
