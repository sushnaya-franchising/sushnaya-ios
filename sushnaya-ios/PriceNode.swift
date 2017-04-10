//
//  PriceCellNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/9/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol PriceNodeDelegate {
    func priceNode(_ node: PriceNode, didTouchPrice price: Price)
}

class PriceNode: ASDisplayNode {
    private(set) var modifierLabel: ASTextNode?
    private(set) var priceButton = ASButtonNode()
    var delegate: PriceNodeDelegate?
    let price: Price
    
    init(price: Price) {
        self.price = price
        super.init()
        
        automaticallyManagesSubnodes = true
        setupSubnodes()
        buildSubnodeHierarchy()        
    }
    
    private func buildSubnodeHierarchy() {
        if let modifierLabel = modifierLabel {
            addSubnode(modifierLabel)
        }
        addSubnode(priceButton)
    }
    
    private func setupSubnodes() {
        setupModifierLabel()
        setupPriceButton()
    }
    
    private func setupModifierLabel() {
        guard let modifierName = price.modifierName else { return }
        
        let modifierLabel = ASTextNode()
        modifierLabel.attributedText = NSAttributedString(string: modifierName, attributes:
            Constants.ProductCellLayout.PriceModifierStringAttributes)
        self.modifierLabel = modifierLabel
    }
    
    private func setupPriceButton() {
        let title = NSAttributedString(string: price.formattedValue, attributes: price.modifierName == nil ?
            Constants.ProductCellLayout.PriceStringAttributes : Constants.ProductCellLayout.PriceWithModifierStringAttributes)
        priceButton.setAttributedTitle(title, for: .normal)
        priceButton.backgroundColor = Constants.ProductCellLayout.PriceButtonBackgroundColor
    }
    
    override func didLoad() {
        super.didLoad()
        
        priceButton.cornerRadius = 5
        priceButton.clipsToBounds = true
        priceButton.addTarget(self, action: #selector(didTouchUpInsidePriceButton), forControlEvents: .touchUpInside)
    }
    
    func didTouchUpInsidePriceButton() {
        delegate?.priceNode(self, didTouchPrice: price)
        print(price.formattedValue)
    }
    
    override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
        var modifierCalculatedSize = CGSize.zero
        
        if let modifierLabel = modifierLabel {
            modifierLabel.textContainerInset = Constants.ProductCellLayout.ModifierTextInsets
            modifierLabel.layoutThatFits(ASSizeRange(min: CGSize.zero, max: constrainedSize))
            modifierCalculatedSize = modifierLabel.calculatedSize
        }
        
        priceButton.contentEdgeInsets = Constants.ProductCellLayout.PriceButtonContentInsets
        priceButton.hitTestSlop = Constants.ProductCellLayout.PriceButtonHitTestSlop
        priceButton.layoutThatFits(ASSizeRange(min: CGSize.zero, max: constrainedSize))
        
        return CGSize(width: modifierCalculatedSize.width + priceButton.calculatedSize.width,
                      height: priceButton.calculatedSize.height)
    }
    
    override func layout() {
        super.layout()
        
        if let modifierLabel = modifierLabel {
            let modifierTitleSize = modifierLabel.calculatedSize
            let priceTitleSize = priceButton.calculatedSize
            let modifierTitleY = (priceTitleSize.height - modifierTitleSize.height)/2
            modifierLabel.frame = CGRect(x: 0, y: modifierTitleY, width: modifierTitleSize.width, height: modifierTitleSize.height)
            priceButton.frame = CGRect(x: modifierTitleSize.width, y: 0, width: priceTitleSize.width, height: priceTitleSize.height)
            
        } else {
            let priceTitleSize = priceButton.calculatedSize
            let priceLayoutHeight = priceTitleSize.height
            let priceLayoutWidth = priceTitleSize.width
            
            priceButton.frame = CGRect(x: 0, y: 0, width: priceLayoutWidth, height: priceLayoutHeight)
        }
    }
}
