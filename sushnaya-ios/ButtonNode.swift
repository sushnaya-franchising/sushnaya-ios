//
//  ButtonNode.swift
//  Food
//
//  Created by Igor Kurylenko on 3/28/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop

class ButtonNode: ASButtonNode {
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted != oldValue {
                isHighlighted ? didHighlight(): didHighlightOff()
            }
        }
    }
    
    private var curAlpha: CGFloat = 1 {
        didSet {
            guard curAlpha != oldValue else { return }
            
            onCurAlphaChanged()
        }
    }
    
    private func onCurAlphaChanged() {
        pop_removeAllAnimations()
        
        if curAlpha < 1 {
            self.alpha = curAlpha
            
        } else {
            let animation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)!
            animation.duration = 1
            animation.toValue = curAlpha
            
            pop_add(animation, forKey: "fading")
        }
    }
    
    func didHighlight() {
        curAlpha = 0.3
    }
    
    func didHighlightOff() {
        curAlpha = 1
    }
}
