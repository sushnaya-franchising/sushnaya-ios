//
//  OrderNavbarNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 5/17/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol OrderNavbarDelegate: class {
    func orderNavbarDidTapBackButton(node: OrderNavbarNode)
}

class OrderNavbarNode: ASDisplayNode {
    fileprivate let chevronUpIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .chevronUp), attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 16), NSForegroundColorAttributeName: PaperColor.Gray800])
    
    fileprivate let backButton = ASButtonNode()
    
    weak var delegate: OrderNavbarDelegate?
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupBackButtonNode()
    }
    
    private func setupBackButtonNode() {
        backButton.setAttributedTitle(chevronUpIconString, for: .normal)
        backButton.setTargetClosure { [unowned self] _ in
            self.delegate?.orderNavbarDidTapBackButton(node: self)
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subnode in subnodes {
            if subnode.hitTest(convert(point, to: subnode), with: event) != nil {
                return true
            }
        }
        return false
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        backButton.hitTestSlop = UIEdgeInsets(top: -22, left: -22, bottom: -22, right: -22)
        backButton.style.preferredSize = CGSize(width: 44, height: 44)
        let backButtonLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(24, 16, 0, 0), child: backButton)
        
        let backButtonRow = ASStackLayoutSpec.horizontal()
        backButtonRow.alignItems = .start
        backButtonRow.children = [backButtonLayout]                
        
        return backButtonRow
    }
}
