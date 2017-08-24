//
//  OrderWithDeliveryViewController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 5/15/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop


class CheckoutViewController: ASViewController<CheckoutContentNode> {
    
    fileprivate var orderVC: OrderViewController!
    fileprivate var addressVC: AddressViewController!
    
    fileprivate var tapRecognizer: UITapGestureRecognizer!
    fileprivate var keyboardHeight: CGFloat = 0
    
    fileprivate var addresses: [Address] {
        return self.app.userSession.settings.addresses
    }
    
    convenience init() {
        let addressVC = AddressViewController()
        let orderVC = OrderViewController()
        
        self.init(node: CheckoutContentNode(orderNode: orderVC.node, addressNode: addressVC.node))
        
        self.orderVC = orderVC
        self.orderVC.delegate = self
        
        self.addressVC = addressVC
        self.addressVC.delegate = self
        
        self.tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))
        self.tapRecognizer.numberOfTapsRequired = 1
        
        self.node.automaticallyManagesSubnodes = true
        self.node.state = addresses.isEmpty ? .editAddress : .initial
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {        
        self.view.endEditing(true)
    }
}

extension CheckoutViewController: AddressViewControllerDelegate {
    func addressViewControllerDidTapBackButton(_ vc: AddressViewController) {
        if addresses.isEmpty {
            self.dismiss(animated: true)
            
        } else {
            self.node.state = .initial
            node.transitionLayout(withAnimation: true, shouldMeasureAsync: false)
        }
    }
    
    func addressViewController(_ vc: AddressViewController, didSubmitAddress address: Address) {
        guard !addresses.isEmpty else { return }
        
        self.node.state = .initial
        node.transitionLayout(withAnimation: true, shouldMeasureAsync: false)
    }
}

extension CheckoutViewController: OrderViewControllerDelegate {
    func orderViewControllerDidTapBackButton(_ vc: OrderViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func orderViewController(_ vc: OrderViewController, didSubmitOrder order: NSObject?) {
        // todo: implement order view controller did submit order
    }
}

enum CheckoutContentNodeState {
    case initial, editAddress
}

class CheckoutContentNode: ASDisplayNode {
    fileprivate var state: CheckoutContentNodeState!
    fileprivate var orderNode: OrderNode!
    fileprivate var addressNode: AddressContentNode!
    
    
    init(orderNode: OrderNode, addressNode: AddressContentNode) {
        super.init()
        self.orderNode = orderNode
        self.addressNode = addressNode
        self.automaticallyManagesSubnodes = true
    }
    
    override func didLoad() {
        super.didLoad()
        
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 3
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASStackLayoutSpec.vertical()
        layout.style.preferredSize = constrainedSize.max
        
        let pusher = ASLayoutSpec()
        let pusherHeight: CGFloat = 78
        pusher.style.height = ASDimension(unit: .points, value: pusherHeight)
        
        let contentSize = CGSize(width: constrainedSize.max.width,
                                 height: constrainedSize.max.height - pusherHeight)
        
        let contentNode: ASDisplayNode!
        
        if self.state == .initial {
            contentNode = self.orderNode
        }else {
            contentNode = self.addressNode
        }
        
        contentNode.style.preferredSize = contentSize
        
        layout.children = [pusher, contentNode]
        
        return layout
    }
    
    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        if self.state == .initial {
            let initialOrderFrame = context.initialFrame(for: addressNode)
            
            orderNode.frame = initialOrderFrame
//            orderNode.alpha = 0
            
            var finalAddressFrame = context.finalFrame(for: orderNode)
            finalAddressFrame.origin.x -= finalAddressFrame.size.width
            
            // todo: use pop to animate transitioning
            UIView.animate(withDuration: 0.4, animations: {
                self.orderNode.frame = context.finalFrame(for: self.orderNode)
//                self.orderNode.alpha = 1
                self.addressNode.frame = finalAddressFrame
//                self.addressNode.alpha = 0
            }, completion: { finished in
                context.completeTransition(finished)
            })
            
        } else {
            var initialAddressFrame = context.initialFrame(for: orderNode)
            initialAddressFrame.origin.x += initialAddressFrame.size.width
            
            addressNode.frame = initialAddressFrame
//            addressNode.alpha = 0
            
            var finalOrderFrame = context.finalFrame(for: addressNode)
            finalOrderFrame.origin.x -= finalOrderFrame.size.width
            
            UIView.animate(withDuration: 0.4, animations: {
                self.addressNode.frame = context.finalFrame(for: self.addressNode)
//                self.addressNode.alpha = 1
                self.orderNode.frame = finalOrderFrame
//                self.orderNode.alpha = 0
            }, completion: { finished in
                context.completeTransition(finished)
            })
        }
    }
}
