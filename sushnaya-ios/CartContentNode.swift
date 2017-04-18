//
//  CartContentNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/13/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class CartContentNode: ASDisplayNode {
    
    let emptyCartMessage = "Нажмите на цену или дважды коснитесь изображения продукта для того, чтобы добавить в корзину."
    
    let cart: Cart
    
    let headerNode = ASTextNode()
    private(set) var emptyCartMessageNode: ASTextNode!
    let cartItemsTableNode = ASTableNode()
    let toolBarNode: CartToolBarNode
    
    init(cart: Cart) {
        self.cart = cart
        self.toolBarNode = CartToolBarNode(cart: cart)
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = PaperColor.White
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupHeaderNode()
        setupEmptyCartMessageNode()
        setupCartItemsTableNode()        
    }
    
    private func setupHeaderNode() {
        headerNode.attributedText = NSAttributedString(string: "Корзина", attributes: Constants.CartLayout.HeaderStringAttributes)
    }
    
    private func setupCartItemsTableNode() {
        cartItemsTableNode.delegate = self
        cartItemsTableNode.dataSource = self
        cartItemsTableNode.allowsSelection = false
    }
    
    private func setupEmptyCartMessageNode() {
        if cart.isEmpty {
            emptyCartMessageNode = ASTextNode()
            emptyCartMessageNode.attributedText = NSAttributedString(string: emptyCartMessage, attributes: Constants.CartLayout.EmptyCartStringAttributes)
        }
    }
    
    override func didLoad() {
        super.didLoad()
        cartItemsTableNode.view.isScrollEnabled = true
        cartItemsTableNode.view.showsHorizontalScrollIndicator = false
        cartItemsTableNode.view.showsVerticalScrollIndicator = false
        cartItemsTableNode.view.separatorStyle = .none
    }
    
    override func layout() {
        super.layout()
        
        let bottomInset = toolBarNode.calculatedSize.height
        cartItemsTableNode.view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {        
        guard !cart.isEmpty else {
            return emptyCartLayoutSpecThatFits(constrainedSize)
        }
        
        let layout = ASStackLayoutSpec.vertical()
        layout.alignItems = .center
        
        headerNode.textContainerInset = Constants.CartLayout.HeaderTextContainerInsets
        let headerHeight = headerNode.attributedText!.size().height +
            Constants.CartLayout.HeaderTextContainerInsets.top + Constants.CartLayout.HeaderTextContainerInsets.bottom
        
        cartItemsTableNode.style.preferredSize = CGSize(width: constrainedSize.max.width,
                                                        height: constrainedSize.max.height - headerHeight)
        
        let insets = UIEdgeInsets(top: CGFloat.infinity, left: 0, bottom: 0, right: 0)
        let toolBarOverlay = ASInsetLayoutSpec(insets: insets, child: toolBarNode)
        let contentLayout = ASOverlayLayoutSpec(child: cartItemsTableNode, overlay: toolBarOverlay)
        
        layout.children = [headerNode, contentLayout]
        
        return layout
    }
    
    private func emptyCartLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASStackLayoutSpec.vertical()
        layout.alignItems = .center
        
        headerNode.textContainerInset = Constants.CartLayout.HeaderTextContainerInsets
        
        let screenHeight = UIScreen.main.bounds.height
        let emptyCartMessageTop = (screenHeight - screenHeight/Constants.GoldenRatio) - (screenHeight - constrainedSize.max.height)
        emptyCartMessageNode.textContainerInset = UIEdgeInsets(top: emptyCartMessageTop, left: 32, bottom: 0, right: 32)
        
        layout.children = [headerNode, emptyCartMessageNode]
            
        return layout
    }
}

extension CartContentNode: ASTableDelegate, ASTableDataSource, UIGestureRecognizerDelegate {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return cart.cartSections.count
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return cart.cartSections[section].items.count
    }
        
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = ABLabel()
        label.insets = Constants.CartLayout.SectionTitleInsets
        label.backgroundColor = Constants.CartLayout.SectionTitleBackgroundColor
        label.attributedText = NSAttributedString(string: cart.cartSections[section].title.uppercased(),
                                                  attributes: Constants.CartLayout.SectionTitleStringAttributes)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.CartLayout.SectionTitleHeight
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let section = cart.cartSections[indexPath.section]
        let cartItems = section.items[indexPath.row]

        return {
            CartItemCellNode(cartItems: cartItems)
        }
    }
}
