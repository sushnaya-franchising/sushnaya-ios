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
    let count: Int
    
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
