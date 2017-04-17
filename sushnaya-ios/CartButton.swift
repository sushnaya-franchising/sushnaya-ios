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

class CartButton: ASControlNode {
    
    let iconNode = ASImageNode()
    let priceBadgeNode = ASTextNode()
    private var originalX: CGFloat!
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
            ensureOriginalX()
            
        case .changed:
            translate(recognizer)
            
        case .ended:
            if originalX - self.view.frame.origin.x >= Constants.CartButtonDragDistanceToPopCartItem {
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
    
    @discardableResult private func ensureOriginalX() -> CGFloat {
        if originalX == nil {
            originalX = self.frame.origin.x
        }
        
        return originalX
    }
    
    private func translate(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        
        guard self.view.frame.origin.x + translation.x <= originalX else {
            return
        }
        
        let curDistance = originalX - self.view.frame.origin.x
        let translateX = translation.x < 0 && curDistance > Constants.CartButtonDragDistanceToPopCartItem ?
            (translation.x * Constants.CartButtonDragDistanceToPopCartItem)/curDistance : translation.x
        
        self.view.translate(translation: CGPoint(x: translateX, y: 0))
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    private func restoreOriginalPosition(_ recognizer: UIPanGestureRecognizer) {
        guard self.frame.origin.x != originalX else {
            return
        }

        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let curDistance = originalX - self.view.frame.origin.x
        let velocityX = translation.x < 0 && curDistance > Constants.CartButtonDragDistanceToPopCartItem ?
            (velocity.x * Constants.CartButtonDragDistanceToPopCartItem)/curDistance : velocity.x
        
        restoreOriginalPosition(velocityX: velocityX)
    }
    
    private func restoreOriginalPosition(velocityX: CGFloat = 0) {
        guard self.frame.origin.x != originalX else {
            return
        }
        
        let positionAnimation = POPSpringAnimation()
        positionAnimation.property = POPAnimatableProperty.property(withName: "originX", initializer: propertyInitializer) as! POPAnimatableProperty
        positionAnimation.toValue = ensureOriginalX()
        positionAnimation.velocity = velocityX
        positionAnimation.springBounciness = 10
        
        self.view.pop_removeAllAnimations()
        self.view.pop_add(positionAnimation, forKey: "restoreOriginalPosition")
    }        
    
    func propertyInitializer(prop: POPMutableAnimatableProperty!) {
        prop.readBlock = { obj, values in
            if let view = obj as? UIView {
                values?[0] = view.frame.origin.x
            }
        }
        
        prop.writeBlock = { obj, values in
            if let x = values?[0],
                let view = obj as? UIView {
                
                view.frame = CGRect(x: x, y: view.frame.origin.y, width: view.frame.width, height: view.frame.height)
            }
        }
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
