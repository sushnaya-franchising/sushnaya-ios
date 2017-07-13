//
//  OrderFormSummarySectionNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 5/18/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OrderFormSummarySectionNode: ASDisplayNode {
    fileprivate var titleTextNode = ASTextNode()
    fileprivate let iconImageNode: ASImageNode = {
        let imageNode = ASImageNode()
        imageNode.contentMode = .center
        return imageNode
    }()
    
    fileprivate let subtotalTitleTextNode = ASTextNode()
    fileprivate let subtotalValueTextNode = ASTextNode()
    fileprivate let deliveryPriceTitleTextNode = ASTextNode()
    fileprivate let deliveryPriceValueTextNode = ASTextNode()
    fileprivate let totalTitleTextNode = ASTextNode()
    fileprivate let totalValueTextNode = ASTextNode()
        
    let cart: Cart
    
    init(cart: Cart) {
        self.cart = cart
        super.init()
        self.automaticallyManagesSubnodes = true
        setupNodes()
    }
    
    private func setupNodes() {
        setupIconImageNode()
        setupTitleTextNode()
        setupSubtotalTitleTextNode()
        setupSubtotalValueTextNode()
        setupDeliveryPriceTitleTextNode()
        setupDeliveryPriceValueTextNode()
        setupTotalTitleTextNode()
        setupTotalValueTextNode()
    }
    
    private func setupIconImageNode() {
        iconImageNode.image = UIImage.fontAwesomeIcon(name: .shoppingBasket, textColor: PaperColor.Gray400, size: CGSize(width: 16, height: 16))
    }
    
    private func setupTitleTextNode() {
        let title = createTitleString()
        titleTextNode.attributedText = NSAttributedString.attributedString(string: title, fontSize: 14, color: PaperColor.Gray800)
    }
    
    private func setupSubtotalTitleTextNode() {
        subtotalTitleTextNode.attributedText = NSAttributedString.attributedString(string: "Сумма:", fontSize: 14, color: PaperColor.Gray, bold: false)
    }
    
    private func setupSubtotalValueTextNode() {
        subtotalValueTextNode.attributedText = NSAttributedString.attributedString(string: cart.sum.formattedValue, fontSize: 14, color: PaperColor.Gray, bold: false)
    }
    
    private func setupDeliveryPriceTitleTextNode() {
        deliveryPriceTitleTextNode.attributedText = NSAttributedString.attributedString(string: "Доставка:", fontSize: 14, color: PaperColor.Gray, bold: false)
    }
    
    private func setupDeliveryPriceValueTextNode() {
        deliveryPriceValueTextNode.attributedText = NSAttributedString.attributedString(string: Price(value: 0, currencyLocale: "ru_RU").formattedValue, fontSize: 14, color: PaperColor.Gray, bold: false)
    }
    
    private func setupTotalTitleTextNode() {
        totalTitleTextNode.attributedText = NSAttributedString.attributedString(string: "Итого:", fontSize: 14, color: PaperColor.Gray800)
    }
    
    private func setupTotalValueTextNode() {
        totalValueTextNode.attributedText = NSAttributedString.attributedString(string: cart.sum.formattedValue, fontSize: 14, color: PaperColor.Gray800)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        iconImageNode.style.preferredSize = CGSize(width: 32, height: 24)
        let iconLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 16, 0, 0), child: iconImageNode)
        
        titleTextNode.textContainerInset = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 16)
        titleTextNode.style.flexGrow = 1
        titleTextNode.style.flexShrink = 1
        
        let iconAndTitle = ASStackLayoutSpec.horizontal()
        iconAndTitle.justifyContent = .start
        iconAndTitle.alignItems = .center
        iconAndTitle.children = [iconLayout, titleTextNode]
        
        let summaryTableLayout = summaryTableLayoutSpecThatFits(constrainedSize)
        
        let layout = ASStackLayoutSpec.vertical()
        layout.spacing = 32
        layout.children = [iconAndTitle, summaryTableLayout]
        
        return layout
    }
    
    private func summaryTableLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let leftColumnLayout = ASStackLayoutSpec.vertical()
        leftColumnLayout.spacing = 8
        leftColumnLayout.children = [subtotalTitleTextNode, deliveryPriceTitleTextNode, totalTitleTextNode]
        
        let rightColumnLayout = ASStackLayoutSpec.vertical()
        rightColumnLayout.spacing = 8
        rightColumnLayout.alignItems = .end
        rightColumnLayout.children = [subtotalValueTextNode, deliveryPriceValueTextNode, totalValueTextNode]
        
        let spacer = ASLayoutSpec()
        spacer.style.flexGrow = 1
        
        let tableLayout = ASStackLayoutSpec.horizontal()
        tableLayout.children = [spacer, leftColumnLayout, ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 8, 0, 56), child: rightColumnLayout)]
        
        return tableLayout
    }
}

extension OrderFormSummarySectionNode {
    fileprivate func createTitleString() -> String {
        var title = ""
        
        for sectionIdx in 0..<cart.sectionsCount {
            let section = cart[sectionIdx]
            
            var count = 0
            for productIdx in 0..<section.itemsCount {
                let cartItem = section[productIdx]
                count += cartItem.count
            }
            
            let delimiter = title.isEmpty ? "": ", "
            title = "\(title)\(delimiter)\(section.title) \(count)"
        }
        
        return title
    }
}
