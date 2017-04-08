//
//  CartButton2.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/8/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import FontAwesome_swift

class CartButton: ASControlNode {
    
    let iconNode = ASImageNode()
    let priceBadgeNode = ASTextNode()
    
    var sumPrice: Price
    
    init(sumPrice: Price) {
        self.sumPrice = sumPrice
        
        super.init()
        
        automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupIconNode()
        setupPriceBadgeNode()
    }
    
    private func setupIconNode() {
        iconNode.image = UIImage.fontAwesomeIcon(name: .shoppingBasket, textColor: PaperColor.Gray400, size: CGSize(width: 32, height: 32))
    }
    
    private func setupPriceBadgeNode() {
        priceBadgeNode.attributedText = NSAttributedString.attributedString(string: sumPrice.formattedValue, fontSize: 12, color: PaperColor.Gray900)
        priceBadgeNode.backgroundColor = PaperColor.Gray300
        priceBadgeNode.cornerRadius = 10
        priceBadgeNode.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        priceBadgeNode.textContainerInset = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        priceBadgeNode.style.layoutPosition = CGPoint(x: 18, y: -15)
        
        iconNode.style.layoutPosition = CGPoint(x: 0, y: 0)
        
        let absoluteSpec = ASAbsoluteLayoutSpec(sizing: .sizeToFit, children: [iconNode, priceBadgeNode])
        absoluteSpec.sizing = .sizeToFit
        
        return absoluteSpec
    }
}
