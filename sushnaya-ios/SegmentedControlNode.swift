//
//  SegmentedControlNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/28/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop

protocol SegmentedControlDelegate: class {
    func segmentedControl(segmentedControl: SegmentedControlNode, didSelectSegment segment: Int)
}

class SegmentedControlNode: ASDisplayNode {
    
    private var buttons = [ASButtonNode]()
    var highlighter = ASDisplayNode()
    weak var delegate: SegmentedControlDelegate?
    var selectedSegment = 0 {
        didSet {
            guard oldValue != selectedSegment else {
                return
            }
            
            guard selectedSegment >= 0 else {
                selectedSegment = 0
                return
            }
            
            guard selectedSegment < buttons.count  else {
                selectedSegment = buttons.count - 1
                return
            }
            
            self.fadeIn(buttons[selectedSegment])
            self.fadeOut(buttons[oldValue])
            self.animateSegmentSelection()
            self.delegate?.segmentedControl(segmentedControl: self, didSelectSegment: selectedSegment)
        }
    }
    
    override init() {
        super.init()
        self.highlighter.backgroundColor = PaperColor.White
        self.backgroundColor = PaperColor.Gray200
        self.automaticallyManagesSubnodes = true
    }
    
    // todo: add NSAttributed sting with string segment key
    func addButton(_ button: ASButtonNode) {
        let segment = buttons.count
        button.addTargetClosure { [unowned self] _ in
            self.selectedSegment = segment
        }
        button.backgroundColor = nil
        buttons.append(button)
    }
    
    override func didLoad() {
        super.didLoad()        
        
        highlighter.cornerRadius = max(cornerRadius - 1, 0)
        highlighter.clipsToBounds = true
        
        for (idx, btn) in buttons.enumerated() {
            if idx != selectedSegment {
                btn.layer.opacity = 0.5
            }
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var maxButtonTextWidth:CGFloat = 0
        buttons.forEach {
            if let bounds = $0.attributedTitle(for: .normal)?.boundingRect(with: CGSize.max, options: .usesLineFragmentOrigin, context: nil) {
                maxButtonTextWidth = max(maxButtonTextWidth, bounds.width)
            }
        }
        
        let buttonWidth = max(maxButtonTextWidth + 10, 44)
        let buttonHeight = max(constrainedSize.max.height, 44)
        
        buttons.forEach {
            $0.style.preferredSize = CGSize(width: buttonWidth, height: buttonHeight)
        }
        
        highlighter.style.preferredSize = CGSize(width: buttonWidth - 4, height: buttonHeight - 4)
        highlighter.style.layoutPosition = CGPoint(x: 2, y: 2)
        
        let stack = ASStackLayoutSpec.horizontal()        
        stack.children = buttons
        stack.style.layoutPosition = CGPoint(x: 0, y: 0)
        
        return ASAbsoluteLayoutSpec(children: [highlighter, stack])
    }
}

fileprivate extension SegmentedControlNode {
    func fadeOut(_ node: ASDisplayNode) {
        if let animation = node.pop_animation(forKey: "opacity") as? POPBasicAnimation {
            animation.toValue = 0.5
            
        } else {
            let animation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
            animation?.toValue = 0.5
            animation?.duration = 0.2
            
            node.layer.pop_add(animation, forKey: "opacity")
        }
    }
    
    func fadeIn(_ node: ASDisplayNode) {
        if let animation = node.pop_animation(forKey: "opacity") as? POPBasicAnimation {
            animation.toValue = 1
            
        } else {
            let animation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
            animation?.toValue = 1
            animation?.duration = 0.2
            
            node.layer.pop_add(animation, forKey: "opacity")
        }
    }
    
    func animateSegmentSelection() {
        let highligherCenterX = (CGFloat(selectedSegment) + 0.5) * (highlighter.bounds.width + 4)
        
        if let animation = highlighter.pop_animation(forKey: "position") as? POPBasicAnimation {
            animation.toValue = highligherCenterX
            
        } else {
            let animation = POPBasicAnimation(propertyNamed: kPOPLayerPositionX)
            animation?.toValue = highligherCenterX
            animation?.duration = 0.2
            
            highlighter.layer.pop_add(animation, forKey: "position")
        }
    }
}
