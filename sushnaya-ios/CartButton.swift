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
import pop

// todo: fix restore initial position
class CartButton: ASControlNode {
    
    let iconNode = ASImageNode()
    let priceBadgeNode = ASTextNode()
    private var centerBeforeGesture: CGPoint!
    let cart: Cart
    
    init(cart: Cart) {
        self.cart = cart
        super.init()
        automaticallyManagesSubnodes = true
        isExclusiveTouch = true
        
        registerEventHandlers()
        setupNodes()
    }
    
    private func registerEventHandlers() {
        EventBus.onMainThread(self, name: DidAddToCart.name) { [unowned self] _ in
            self.animatePriceUpdate()
            self.updatePriceBadgeText()
        }
        
        EventBus.onMainThread(self, name: DidRemoveFromCart.name) { [unowned self] _ in
            self.animatePriceUpdate()
            self.updatePriceBadgeText()
        }
    }
    
    deinit {
        EventBus.unregister(self)
    }
    
    private func animatePriceUpdate() {
        let sum = cart.sum.value
        
        guard sum != 0 else {
            animatePriceDisappearing()
            return
        }
        
        guard !priceBadgeNode.isHidden else {
            animatePriceAppearing()
            return
        }
        
        let animation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        animation?.fromValue = NSValue.init(cgSize: CGSize(width: 0.9, height: 0.9))
        animation?.toValue = NSValue.init(cgSize: CGSize(width: 1, height: 1))
        animation?.springBounciness = 20
        
        priceBadgeNode.pop_removeAllAnimations()
        priceBadgeNode.pop_add(animation, forKey: "scale")
    }
    
    private func animatePriceDisappearing() {
        let animation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        animation?.toValue = NSValue.init(cgSize: CGSize(width: 0, height: 0))
        animation?.duration = 0.2
        animation?.completionBlock = { [unowned self] _ in
            self.priceBadgeNode.isHidden = true
        }
        
        priceBadgeNode.pop_removeAllAnimations()
        priceBadgeNode.pop_add(animation, forKey: "scale")
    }
    
    private func animatePriceAppearing() {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        animation?.fromValue = NSValue.init(cgSize: CGSize(width: 0, height: 0))
        animation?.toValue = NSValue.init(cgSize: CGSize(width: 1, height: 1))
        animation?.springBounciness = 10
        
        priceBadgeNode.pop_removeAllAnimations()
        priceBadgeNode.pop_add(animation, forKey: "scale")
        priceBadgeNode.isHidden = false
    }
    
    private func setupNodes() {
        setupIconNode()
        setupPriceBadgeNode()
    }
    
    private func setupIconNode() {
        iconNode.image = UIImage.fontAwesomeIcon(name: .shoppingBasket, textColor: PaperColor.Gray400, size: CGSize(width: 32, height: 32))
    }
    
    private func setupPriceBadgeNode() {
        updatePriceBadgeText()
        priceBadgeNode.backgroundColor = PaperColor.Gray300
        priceBadgeNode.cornerRadius = 10
        priceBadgeNode.clipsToBounds = true
        priceBadgeNode.isHidden = cart.sum.value == 0
    }
    
    private func updatePriceBadgeText() {
        priceBadgeNode.attributedText = NSAttributedString(string: cart.sum.formattedValue, attributes: Constants.CartButtonBadgeStringAttributes)
    }
    
    override func didLoad() {
        super.didLoad()
        
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanGesture(_:)))
        
        self.view.addGestureRecognizer(recognizer)
    }
    
    func didPanGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            self.view.pop_removeAllAnimations()
            initCenterBegoreGesture(recognizer)
            
        case .changed:
            translate(recognizer)
            
        case .ended:
            if centerBeforeGesture.x - self.view.center.x >= Constants.CartButtonDragDistanceToPopCartItem {
                popCartItem()
            }
            restoreOriginalPosition(recognizer)
            
        default:
            restoreOriginalPosition(recognizer)
        }
    }
    
    private func popCartItem() {
        if let _ = cart.pop() {
            AudioServicesPlaySystemSound(1155)
        }
    }
    
    private func initCenterBegoreGesture(_ recognizer: UIPanGestureRecognizer) {
        if centerBeforeGesture == nil {
            centerBeforeGesture = recognizer.view?.center
        }
    }
    
    private func translate(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        
        guard self.view.center.x + translation.x <= centerBeforeGesture.x else {
            return
        }
        
        let curDistance = centerBeforeGesture.x - self.view.center.x
        let translateX = translation.x < 0 && curDistance > Constants.CartButtonDragDistanceToPopCartItem ?
            (translation.x * Constants.CartButtonDragDistanceToPopCartItem)/curDistance : translation.x
        
        self.view.translate(translation: CGPoint(x: translateX, y: 0))
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    private func restoreOriginalPosition(_ recognizer: UIPanGestureRecognizer) {
        guard self.view.center != centerBeforeGesture else {
            return
        }

        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let curDistance = centerBeforeGesture.x - self.view.center.x
        let velocityX = translation.x < 0 && curDistance > Constants.CartButtonDragDistanceToPopCartItem ?
            (velocity.x * Constants.CartButtonDragDistanceToPopCartItem)/curDistance : velocity.x
        
        let positionAnimation = POPSpringAnimation(propertyNamed: kPOPViewCenter)
        positionAnimation?.toValue = centerBeforeGesture
        positionAnimation?.velocity = NSValue.init(cgPoint: CGPoint(x: velocityX, y: 0))
        positionAnimation?.springBounciness = 10
        
        self.pop_removeAllAnimations()
        self.view.pop_add(positionAnimation, forKey: "restoreOriginalPosition")
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        hitTestSlop = UIEdgeInsets(top: -15, left: -6, bottom: -6, right: -6)
        priceBadgeNode.textContainerInset = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        priceBadgeNode.style.layoutPosition = CGPoint(x: 18, y: -15)
        
        iconNode.style.layoutPosition = CGPoint(x: 0, y: 0)
        
        let absoluteSpec = ASAbsoluteLayoutSpec(sizing: .sizeToFit, children: [iconNode, priceBadgeNode])
        absoluteSpec.sizing = .sizeToFit
        
        return absoluteSpec
    }
}
