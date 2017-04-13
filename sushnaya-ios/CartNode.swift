//
//  CartNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/13/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import FontAwesome_swift

protocol CartNodeDelegate {
    func cartNodeDidTouchUpInsideCloseButton()
}

class CartNode: ASDisplayNode {
    
    let closeButton = ASButtonNode()
    let iconNode = ASImageNode()
    let cartContentNode: CartContentNode
    var delegate: CartNodeDelegate?
    
    
    init(cart: Cart) {
        cartContentNode = CartContentNode(cart: cart)
        super.init()
        
        automaticallyManagesSubnodes = true
        
        iconNode.image = UIImage.fontAwesomeIcon(name: .shoppingBasket, textColor: PaperColor.White, size: CGSize(width: 130, height: 130))
        closeButton.addTarget(self, action: #selector(didTouchUpInsideCloseButton), forControlEvents: .touchUpInside)
    }
    
    func didTouchUpInsideCloseButton() {
        delegate?.cartNodeDidTouchUpInsideCloseButton()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let backLayout = backLayoutSpecThatFits(constrainedSize)
        let frontLayout = frontLayoutSpecThatFits(constrainedSize)
        
        return ASOverlayLayoutSpec(child: backLayout, overlay: frontLayout)
    }
    
    private func backLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let backLayout = ASStackLayoutSpec.vertical()
        backLayout.alignItems = .center
        
        let backPusher = ASLayoutSpec()
        backPusher.style.height = ASDimension(unit: .points, value: 24)
        
        iconNode.style.preferredSize = iconNode.image!.size
        
        backLayout.children = [backPusher, iconNode]
        
        closeButton.style.height = ASDimension(unit: .points, value: 78)
        
        return ASOverlayLayoutSpec(child: backLayout, overlay: closeButton)
    }
    
    private func frontLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let frontLayout = ASStackLayoutSpec.vertical()
        
        let frontPusher = ASLayoutSpec()
        frontPusher.style.height = ASDimension(unit: .points, value: 78)
        
        let contentLayout = contentLayoutSpecThatFits(constrainedSize)
        
        frontLayout.children = [frontPusher, contentLayout]
        
        return frontLayout
    }
    
    private func contentLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let contentLayout = ASStackLayoutSpec.vertical()
        contentLayout.style.flexGrow = 1.0
        cartContentNode.style.flexGrow = 1.0
        
        contentLayout.children = [cartContentNode]
        
        return contentLayout
    }
}
