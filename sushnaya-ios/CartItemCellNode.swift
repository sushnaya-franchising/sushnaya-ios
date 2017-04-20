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
import pop

struct CartItemCellContext {
    var table: ASTableNode
    var cartItems: [CartItem]
    
    var product: Product? {
        return cartItems.isEmpty ? nil: cartItems[0].product
    }
    
    var price: Price? {
        return cartItems.isEmpty ? nil: cartItems[0].price
    }
}

class CartItemCellNode: ASCellNode {
    
    let countNode = ASTextNode()
    let titleNode = ASTextNode()
    private(set) var priceModifierNameNode: ASTextNode?
    let priceNode = ASTextNode()
    let optionsButtonNode = ASButtonNode()
    
    fileprivate var context: CartItemCellContext
    fileprivate let product: Product
    fileprivate let price: Price
    
    fileprivate var _currenctGestureHandler: GestureHandler!
    fileprivate var _defaultGestureHandler: GestureHandler!
    fileprivate var _nopGestureHandler: GestureHandler!
    
    init(context: CartItemCellContext) {
        self.context = context
        self.product = context.product!
        self.price = context.price!
        
        super.init()
        
        _nopGestureHandler = NopGestureHandler()
        _defaultGestureHandler = DefaultGestureHandler(node: self)
        _currenctGestureHandler = _nopGestureHandler
        
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
                self.context.cartItems.append(event.cartItem)
                self.animateCountUpdate()
                self.animatePriceUpdate()
                self.updateView()
            }
        }
        
        EventBus.onMainThread(self, name: DidRemoveFromCartEvent.name) { [unowned self] (notification) in
            guard let event = notification.object as? DidRemoveFromCartEvent else {
                return
            }
            
            if event.cartItem.product == self.product && event.cartItem.price == self.price {
                for idx in self.context.cartItems.indices where self.context.cartItems[idx].id == event.cartItem.id {
                    self.context.cartItems.remove(at: idx)
                    break
                }
                self.animateCountUpdate()
                self.animatePriceUpdate()
                self.updateView()
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
        updateCountNodeText(count: self.context.cartItems.count)
    }
    
    private func updateView() {
        updateCountNodeText(count: self.context.cartItems.count)
        updatePriceNodeText()
        
        if self.context.cartItems.count == 0 {
            if let indexPath = self.context.table.indexPath(for: self) {
                if self.context.table.numberOfRows(inSection: indexPath.section) == 1 {
                    self.context.table.deleteSections([indexPath.section], with: .left)
                        
                } else {
                    self.context.table.deleteRows(at: [indexPath], with: .left)
                }
            }            
        }
    }
    
    fileprivate func updateCountNodeText(count: Int) {
        countNode.attributedText = NSAttributedString(string: count == 0 ? "-" : count.description,
            attributes: Constants.CartLayout.ItemCountStringAttributes)
    }
    
    private func setupTitleNode() {
        titleNode.attributedText = NSAttributedString(string: product.title.uppercased(),
                                                      attributes: Constants.CartLayout.ItemTitleStringAttributes)
    }
    
    private func setupPriceNode() {
        updatePriceNodeText()
    }
    
    private func updatePriceNodeText() {
        let zeroPrice = Price.zero(currencyLocale: price.currencyLocale, modifierName: price.modifierName)
        let sum = self.context.cartItems.reduce(zeroPrice, {result, cartItem in  result + cartItem.price})
        
        priceNode.attributedText = NSAttributedString(string: sum.formattedValue,
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
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(CartItemCellNode.didPanGesture(_:)))
        recognizer.delegate = self
        self.view.addGestureRecognizer(recognizer)
    }
    
    func didPanGesture(_ recognizer: UIPanGestureRecognizer) {
        _currenctGestureHandler.didPanGesture(recognizer)
    }
    
    private func animateCountUpdate() {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        animation?.fromValue = NSValue.init(cgSize: CGSize(width: 0.9, height: 0.9))
        animation?.toValue = NSValue.init(cgSize: CGSize(width: 1, height: 1))
        animation?.springBounciness = 20
        
        countNode.pop_removeAllAnimations()
        countNode.pop_add(animation, forKey: "scale")
    }
    
    private func animatePriceUpdate() {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        animation?.fromValue = NSValue.init(cgSize: CGSize(width: 0.9, height: 0.9))
        animation?.toValue = NSValue.init(cgSize: CGSize(width: 1, height: 1))
        animation?.springBounciness = 20
        
        priceNode.pop_removeAllAnimations()
        priceNode.pop_add(animation, forKey: "scale")
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASStackLayoutSpec.horizontal()
        layout.alignItems = .start
        layout.justifyContent = .start
        
        let countNodeLayout = countLayoutSpecThatFits(constrainedSize)
        let titleNodeLayout = titleLayoutSpecThatFits(constrainedSize)
        let priceLayout = priceLayoutSpecThatFits(constrainedSize)
        
        optionsButtonNode.style.preferredSize = CGSize(width: 56, height: 40)
        
        let spacer = ASDisplayNode()
        spacer.style.maxSize = CGSize(width: 16, height: 32)
        spacer.style.flexGrow = 1.0
    
        layout.children = [countNodeLayout, titleNodeLayout, spacer, priceLayout, optionsButtonNode]
        
        return layout
    }
    
    private func countLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        countNode.style.minWidth = ASDimension(unit: .points, value: 16)
        
        return ASInsetLayoutSpec(insets: Constants.CartLayout.ItemCountInsets, child: countNode)
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
        priceNode.style.minWidth = ASDimension(unit: .points, value: 56)
        
        return ASInsetLayoutSpec(insets: Constants.CartLayout.ItemPriceInsets, child: priceNode)
    }
}

extension CartItemCellNode: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        
        let velocity = gestureRecognizer.velocity(in: self.view)
        
        _currenctGestureHandler = abs(velocity.y) < abs(velocity.x) ? _defaultGestureHandler: _nopGestureHandler
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        
        let velocity = gestureRecognizer.velocity(in: self.view)
        
        return abs(velocity.y) > abs(velocity.x)
    }
}

fileprivate protocol GestureHandler {
    func didPanGesture(_ recognizer: UIPanGestureRecognizer)
}

fileprivate class DefaultGestureHandler: GestureHandler {
    private var node: CartItemCellNode
    
    private var checkpoint: CGPoint!
    
    private var didPanLeft: (() -> ())!
    private var didPanRight: (() -> ())!
    private var udpateCheckpoint:((CGPoint) -> ())!
    private var didEnd: (() -> ())!
    private var defaultDidPanLeft:(() -> ())!
    private var defaultDidPanRight:(() -> ())!
    private var defaultUpdateCheckpoint: ((CGPoint) -> ())!
    
    init(node: CartItemCellNode) {
        self.node = node
        
        setDefaultState()
    }
    
    private func setDefaultState() {
        didPanLeft = { [unowned self] in
            if self.node.context.cartItems.count == 1 {
                self.node.updateCountNodeText(count: 0)
                self.setWillRemoveState()
                
            } else {
                RemoveFromCartEvent.fire(product: self.node.product, withPrice: self.node.price)
            }
        }
        
        didPanRight = { [unowned self] in
            AddToCartEvent.fire(product: self.node.product, withPrice: self.node.price)
        }
        
        udpateCheckpoint = {[unowned self] checkpoint in
            self.checkpoint = checkpoint
        }
        
        didEnd = {}
    }
    
    private func setWillRemoveState() {
        didPanLeft = {}
        
        didPanRight = { [unowned self] in
            self.node.updateCountNodeText(count: 1)
            self.setDefaultState()
        }
        
        udpateCheckpoint = { checkpoint in
            if checkpoint.x >= self.checkpoint.x + Constants.CartLayout.DistanceToChageCount {
                self.checkpoint = checkpoint
            }
        }
        
        didEnd = { [unowned self] in
            RemoveFromCartEvent.fire(product: self.node.product, withPrice: self.node.price)
        }
    }
    
    func didPanGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            checkpoint = recognizer.location(in: node.view.superview)
            
        case .changed:
            let point = recognizer.location(in: node.view.superview)
            let distance = point.x - checkpoint.x
            
            guard abs(distance) > Constants.CartLayout.DistanceToChageCount else {
                return
            }
            
            udpateCheckpoint(point)
            
            if distance < 0 {
                didPanLeft()
                
            } else {
                didPanRight()
            }
        
        case .ended:
            didEnd()
            
        default:
            break
        }
    }
}

fileprivate class NopGestureHandler: GestureHandler {
    func didPanGesture(_ recognizer: UIPanGestureRecognizer) {
        // nop
    }
}
