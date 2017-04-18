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
    
    let cartItem: CartItem
    var count: Int {
        didSet {
            if oldValue != count {
                updateCountNodeText(count)
            }
        }
    }
    
    let countNode = ASTextNode()
    let titleNode = ASTextNode()
    private(set) var priceModifierNameNode: ASTextNode?
    let priceNode = ASTextNode()
    let optionsButtonNode = ASButtonNode()
    
    init(cartItem: CartItem, count: Int) {
        self.cartItem = cartItem
        self.count = count
        super.init()
        
        automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupCountNode()
        setupTitleNode()
        setupPriceModifierNameNode()
        setupPriceNode()
        setupOptionsButtonNode()
    }
    
    private func setupCountNode() {
        updateCountNodeText(count)
    }
    
    private func updateCountNodeText(_ count: Int) {
        countNode.attributedText = NSAttributedString(string: "\(count)",
            attributes: Constants.CartLayout.ItemCountStringAttributes)
    }
    
    private func setupTitleNode() {
        titleNode.attributedText = NSAttributedString(string: cartItem.product.title.uppercased(),
                                                      attributes: Constants.CartLayout.ItemTitleStringAttributes)
    }
    
    private func setupPriceNode() {
        priceNode.attributedText = NSAttributedString(string: cartItem.price.formattedValue,
                                                      attributes: Constants.CartLayout.ItemPriceStringAttributes)
    }
    
    private func setupPriceModifierNameNode() {
        if let modifierName = cartItem.price.modifierName {
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
    
    var _gestureStartPoint:CGPoint!
    var _shouldRecognize = true
    
    func didPanGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            _gestureStartPoint = recognizer.location(in: self.view.superview)
            
        case .changed:
            let translation = recognizer.translation(in: self.view.superview)
            
            guard abs(translation.y) < 16 else {
                _shouldRecognize = false
                return
            }
            
            guard _shouldRecognize else {
                return
            }
            
            let point = recognizer.location(in: self.view.superview)
            
            self.updateCountNodeText(Int(max(self.count + Int((point.x - _gestureStartPoint.x)/32), 0)))
            
        case .ended:
            if _shouldRecognize {
                let point = recognizer.location(in: self.view)
                self.count = Int(max(self.count + Int((point.x - _gestureStartPoint.x)/32), 0))
            }
            
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
