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
    
    unowned let cart: Cart
    
    let headerNode = ASTextNode()
    let emptyCartMessageNode = ASTextNode()
    let cartItemsTableNode = ASTableNode()
    let toolBarNode: CartToolbarNode
    private var eventHandlersBound = false
    
    init(cart: Cart) {
        self.cart = cart
        self.toolBarNode = CartToolbarNode(cart: cart)
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
        cartItemsTableNode.delegate = cart
        cartItemsTableNode.dataSource = cart
        cartItemsTableNode.allowsSelection = false
    }
    
    private func setupEmptyCartMessageNode() {
        emptyCartMessageNode.attributedText = NSAttributedString(string: emptyCartMessage, attributes: Constants.CartLayout.EmptyCartStringAttributes)
    }

    func bindEventHandlers() {
        guard !eventHandlersBound else {
            return
        }
        
        EventBus.onMainThread(self, name: DidAddToCartEvent.name) { [unowned self] (notification) in
            guard let event = notification.object as? DidAddToCartEvent else {
                return
            }

            let indexPath = IndexPath(item: event.productIdx, section: event.sectionIdx)
            if let cell = self.cartItemsTableNode.nodeForRow(at: indexPath) as? CartItemCellNode {
                cell.context = event.cart.createCellContext(
                        sectionIdx: event.sectionIdx, productIdx: event.productIdx)
            }
        }

        EventBus.onMainThread(self, name: DidRemoveFromCartEvent.name) { [unowned self] (notification) in
            guard let event = notification.object as? DidRemoveFromCartEvent else {
                return
            }

            switch event.context {
                
            case let ctx as RemoveUnitContext where ctx.allUnitsWasRemoved:
                let indexPath = IndexPath(item: ctx.productIdx, section: ctx.sectionIdx)
                self.cartItemsTableNode.deleteRows(at: [indexPath], with: .left)
                
            case let ctx as RemoveUnitContext where !ctx.allUnitsWasRemoved:
                let indexPath = IndexPath(item: ctx.productIdx, section: ctx.sectionIdx)
                if let cell = self.cartItemsTableNode.nodeForRow(at: indexPath) as? CartItemCellNode {
                    cell.context = ctx.cart.createCellContext(
                        sectionIdx: ctx.sectionIdx, productIdx: ctx.productIdx)
                }
                
            case let ctx as RemoveSectionContext:
                self.cartItemsTableNode.deleteSections([ctx.sectionIdx], with: .left)
                
            default:
                break
            }
        }
        
        eventHandlersBound = true
    }

    func unbindEventHandler() {
        if eventHandlersBound {
            EventBus.unregister(self)
            
            eventHandlersBound = false
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

extension Cart: ASTableDelegate, ASTableDataSource, UIGestureRecognizerDelegate {
    func numberOfSections(in tableNode: ASTableNode) -> Int {        
        return sectionsCount
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {        
        return self[section].itemsCount
    }
        
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < sectionsCount else {
            return nil
        }
        
        let label = Label()
        label.insets = Constants.CartLayout.SectionTitleInsets
        label.backgroundColor = Constants.CartLayout.SectionTitleBackgroundColor
        label.attributedText = NSAttributedString(string: self[section].title.uppercased(),
                                                  attributes: Constants.CartLayout.SectionTitleStringAttributes)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.CartLayout.SectionTitleHeight
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let context = createCellContext(sectionIdx: indexPath.section, productIdx: indexPath.item)

        return {
            CartItemCellNode(context: context)
        }
    }

    func createCellContext(sectionIdx: Int, productIdx: Int) -> CartItemCellContext {
        let product = self[sectionIdx][productIdx].product
        let price = self[sectionIdx][productIdx].price
        let count = self[sectionIdx][productIdx].count
        let sum = self[sectionIdx][productIdx].sum

        return CartItemCellContext(product: product, price: price, count: count, sum: sum)
    }
}
