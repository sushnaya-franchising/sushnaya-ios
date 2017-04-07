//
//  ShoppingButton.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/6/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import pop

protocol ShoppingButtonDelegate {
    func shoppingButton(_ shoppingButton: ShoppingButton, didPanAtPoint origin: CGPoint)
}

class ShoppingButton: PaperButton {
    static let DefaultShoppingButtonSize: CGFloat = 66
    
    var size: CGFloat = ShoppingButton.DefaultShoppingButtonSize {
        didSet {
            updateFrame()
        }
    }
    
    var delegate: ShoppingButtonDelegate?
    
    // MARK: Initialization
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }

    private func setup() {
        updateFrame()
        
        backgroundColor = PaperColor.Gray100
        icon = createShoppingBasketImage()
        
        isExclusiveTouch = true        
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(_didPanGesture(_:)))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    private func createShoppingBasketImage() -> UIImage {
        return UIImage.fontAwesomeIcon(name: .shoppingBasket, textColor: PaperColor.Gray, size: CGSize(width: 25, height: 25))
    }
    
    private func updateFrame() {
        frame.size = CGSize(width: size, height: size)
        cornerRadius = Float(size) / 2
    }
    
    func _didPanGesture(_ recognizer: UIPanGestureRecognizer) {
        recognizeGesture(recognizer, didEndPanGesture: restoreDraggedViewPosition)
    }
    
    private func recognizeGesture(_ recognizer: UIPanGestureRecognizer, didEndPanGesture: (() -> ())?) {
        switch recognizer.state {
        case .began:
            didBeginPanGesture(recognizer)
            
        case .changed:
            didPanGesture(recognizer)
            
        case .ended:
            didEndPanGesture?()
            
        default: break
        }
    }
    
    private var draggedView: UIView!
    private var draggedViewCenterBeforeGesture: CGPoint!
    
    private func didBeginPanGesture(_ recognizer: UIPanGestureRecognizer) {
        draggedView = recognizer.view!
        draggedViewCenterBeforeGesture = draggedView.center
    }
    
    private func didPanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: superview)
        let view = recognizer.view!
        
        translateView(view, translation: translation)
        
        recognizer.setTranslation(CGPoint.zero, in: superview)
    }
    
    private func translateView(_ view: UIView, translation: CGPoint) {
        let frame = view.frame
        let x = frame.origin.x + translation.x
        let y = frame.origin.y + translation.y
        let origin = CGPoint(x: x, y: y)
        
        view.frame = CGRect(origin: origin, size: frame.size)
        
        delegate?.shoppingButton(self, didPanAtPoint: origin)
    }
    
    private func restoreDraggedViewPosition() {
        let positionAnimation = POPSpringAnimation.viewCenter(
                toValue: draggedViewCenterBeforeGesture.asPoint, velocity: (8,8))
            
        draggedView.pop_add(positionAnimation, forKey: "restorePosition")
    }
}
