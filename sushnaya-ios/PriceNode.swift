//
//  PriceCellNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/9/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import AVFoundation
import pop

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
        priceButton.addTarget(self, action: #selector(scalePriceToBig), forControlEvents: [.touchDown, .touchDragInside])
        priceButton.addTarget(self, action: #selector(didTouchUpInsidePriceButton), forControlEvents: .touchUpInside)
        priceButton.addTarget(self, action: #selector(scalePriceToDefault), forControlEvents: [.touchDragOutside, .touchCancel])
    }
    
    func didTouchUpInsidePriceButton() {
        delegate?.priceNode(self, didTouchPrice: price)
        
        animateExplosion()
    }
    
    func scalePriceToBig() {
        let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        scaleAnimation?.toValue = NSValue.init(cgSize: CGSize(width: 1.2, height: 1.2))
        scaleAnimation?.duration = 0.3
        priceButton.pop_add(scaleAnimation, forKey: "scaleToSmall")
    }
    
    func scalePriceToDefault() {
        let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        scaleAnimation?.toValue = NSValue.init(cgSize: CGSize(width: 1, height: 1))
        priceButton.pop_add(scaleAnimation, forKey: "scaleToDefault")
    }
    
    private func animateExplosion() {
        let scaleAnimation = POPDecayAnimation(propertyNamed: kPOPViewScaleXY)
        scaleAnimation?.velocity = NSValue.init(cgPoint: CGPoint(x: 25, y: 25))
        
        let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        alphaAnimation?.toValue = 0
        alphaAnimation?.duration = 0.07
        alphaAnimation?.completionBlock = { [unowned self] _ in
            self.animateBirth()
        }
        
        AudioServicesPlaySystemSound(1156)
        self.priceButton.pop_removeAllAnimations()
        priceButton.pop_add(scaleAnimation, forKey: "scaleOut")
        priceButton.pop_add(alphaAnimation, forKey: "fadeOut")
    }
    
    private func animateBirth() {
        let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        scaleAnimation?.fromValue = NSValue.init(cgSize: CGSize(width: 0.5, height: 0.5))
        scaleAnimation?.toValue = NSValue.init(cgSize: CGSize(width: 1, height: 1))
        scaleAnimation?.springBounciness = 6
        scaleAnimation?.springSpeed = 6
        
        let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        alphaAnimation?.toValue = 1
        alphaAnimation?.duration = 0.1
        
        self.priceButton.pop_removeAllAnimations()
        priceButton.pop_add(alphaAnimation, forKey: "fadeIn")
        priceButton.pop_add(scaleAnimation, forKey: "scaleIn")
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASStackLayoutSpec.horizontal()
        layout.alignItems = .center
        
        if let modifierLabel = modifierLabel {
            modifierLabel.textContainerInset = Constants.ProductCellLayout.ModifierTextInsets
            modifierLabel.style.flexShrink = 1.0
            layout.children?.append(modifierLabel)
        }
        
        let spacer = ASLayoutSpec()
        spacer.style.flexGrow = 1.0
        layout.children?.append(spacer)
        
        priceButton.contentEdgeInsets = Constants.ProductCellLayout.PriceButtonContentInsets
        priceButton.hitTestSlop = UIEdgeInsets(top: -Constants.ProductCellLayout.PriceButtonHitTestSlopPadding, left: 0,
                                               bottom: -Constants.ProductCellLayout.PriceButtonHitTestSlopPadding, right: 0)
        let priceButtonLayout = ASInsetLayoutSpec(insets: Constants.ProductCellLayout.PriceButtonInsets, child: priceButton)
        
        layout.children?.append(priceButtonLayout)
        
        return layout
    }    
}
