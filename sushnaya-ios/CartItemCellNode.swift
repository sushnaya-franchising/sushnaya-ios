//
//  CartItemCellNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/14/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import FontAwesome_swift

class CartItemCellNode: ASCellNode {
    
    let countNode = ASTextNode()
    let titleNode = ASTextNode()
    private(set) var priceModifierNameNode: ASTextNode?
    let priceNode = ASTextNode()
    let optionsButtonNode = ASButtonNode()
    
    let product: Product
    let price: Price
    var cartItems: [CartItem]
    
    init(cartItems: [CartItem]) {
        self.cartItems = cartItems
        self.product = cartItems[0].product
        self.price = cartItems[0].price
        super.init()
        automaticallyManagesSubnodes = true
        setupNodes()
        registerEventHandlers()
    }
    
    deinit {
        EventBus.unregister(self)
    }
    
    private func registerEventHandlers() {
        EventBus.onMainThread(self, name: DidAddToCartEvent.name) { [unowned self] (notification) in
            guard let event = notification.object as? DidAddToCartEvent else {
                return
            }
            
            if event.cartItem.product == self.product && event.cartItem.price == self.price {
                self.cartItems.append(event.cartItem)
                self.updateCountNodeText(self.cartItems.count)
            }
        }
        
        EventBus.onMainThread(self, name: DidRemoveFromCartEvent.name) { [unowned self] (notification) in
            guard let event = notification.object as? DidRemoveFromCartEvent else {
                return
            }
            
            if event.cartItem.product == self.product && event.cartItem.price == self.price {
                for idx in self.cartItems.indices where self.cartItems[idx].id == event.cartItem.id {
                    self.cartItems.remove(at: idx)
                    break
                }                
                self.updateCountNodeText(self.cartItems.count)
            }
        }
    }
    
    private func setupNodes() {
        setupCountNode()
        setupTitleNode()
        setupPriceModifierNameNode()
        setupPriceNode()
        setupOptionsButtonNode()
    }
    
    private func setupCountNode() {
        updateCountNodeText(cartItems.count)
    }
    
    private func updateCountNodeText(_ count: Int) {
        countNode.attributedText = NSAttributedString(string: "\(cartItems.count)",
            attributes: Constants.CartLayout.ItemCountStringAttributes)
    }
    
    private func setupTitleNode() {
        titleNode.attributedText = NSAttributedString(string: product.title.uppercased(),
                                                      attributes: Constants.CartLayout.ItemTitleStringAttributes)
    }
    
    private func setupPriceNode() {
        priceNode.attributedText = NSAttributedString(string: price.formattedValue,
                                                      attributes: Constants.CartLayout.ItemPriceStringAttributes)
    }
    
    private func setupPriceModifierNameNode() {
        if let modifierName = price.modifierName {
            priceModifierNameNode = ASTextNode()
            priceModifierNameNode!.attributedText = NSAttributedString(string: "(\(modifierName))",
                                                      attributes: Constants.CartLayout.ItemPriceModifierNameStringAttributes)
        }
    }
    
    private func setupOptionsButtonNode() {
        let title = NSAttributedString(string: String.fontAwesomeIcon(name: .ellipsisH), attributes: [
                NSFontAttributeName: UIFont.fontAwesome(ofSize: 16),
                NSForegroundColorAttributeName: PaperColor.Gray
            ])
        optionsButtonNode.setAttributedTitle(title, for: .normal)
    }
    
    override func didLoad() {
        super.didLoad()
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanGesture(_:)))                
        recognizer.delegate = self
        self.view.addGestureRecognizer(recognizer)
    }
    
    var _checkpoint:CGPoint!
    var _shouldRecognize = true
    
    func didPanGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            _checkpoint = recognizer.location(in: self.view.superview)
            
        case .changed:
            guard _shouldRecognize else {
                return
            }
            
            let point = recognizer.location(in: self.view.superview)
            let distance = point.x - _checkpoint.x
            
            guard abs(distance) > 30 else {
                return
            }
            
            if distance < 0 {
                RemoveFromCartEvent.fire(product: product, withPrice: price)
                
            } else {
                AddToCartEvent.fire(product: product, withPrice: price)
            }
                
            _checkpoint = point
            
        case .ended:
            // todo: remove from cart if needed
            
            _shouldRecognize = true
            
        default:
            break
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASStackLayoutSpec.horizontal()
        layout.alignItems = .start
        layout.justifyContent = .start
        
        let countNodeLayout = ASInsetLayoutSpec(insets: Constants.CartLayout.ItemCountInsets, child: countNode)
        let titleNodeLayout = titleLayoutSpecThatFits(constrainedSize)
        let priceLayout = priceLayoutSpecThatFits(constrainedSize)
        
        optionsButtonNode.style.preferredSize = CGSize(width: 56, height: 40)
        
        let spacer = ASDisplayNode()
        spacer.style.maxSize = CGSize(width: 16, height: 32)
        spacer.style.flexGrow = 1.0
    
        layout.children = [countNodeLayout, titleNodeLayout, spacer, priceLayout, optionsButtonNode]
        
        return layout
    }
    
    private func titleLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        guard let priceModifierNameNode = priceModifierNameNode else {
            return titleOnlyLayoutSpecThatFits(constrainedSize)
        }
        
        return titleWithPriceModifierLayoutSpecThatFits(
            constrainedSize, priceModifierNameNode: priceModifierNameNode)
    }
    
    private func titleOnlyLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASInsetLayoutSpec(insets: Constants.CartLayout.ItemTitleInsets, child: titleNode)
        layout.style.flexShrink = 1.0
        
        return layout
    }
    
    private func titleWithPriceModifierLayoutSpecThatFits(_ constrainedSize: ASSizeRange, priceModifierNameNode: ASTextNode) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec.vertical()
        stack.children = [titleNode, priceModifierNameNode]
        
        let layout = ASInsetLayoutSpec(insets: Constants.CartLayout.ItemTitleInsets, child: stack)
        layout.style.flexShrink = 1.0
        
        return layout
    }
    
    private func priceLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASInsetLayoutSpec(insets: Constants.CartLayout.ItemPriceInsets, child: priceNode)
        
        return layout
    }
}

extension CartItemCellNode: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        
        let velocity = gestureRecognizer.velocity(in: self.view)
        
        _shouldRecognize = abs(velocity.y) < abs(velocity.x)
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        
        let velocity = gestureRecognizer.velocity(in: self.view)
        
        return abs(velocity.y) > abs(velocity.x)
    }
}
