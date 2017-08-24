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
    fileprivate let dismissIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .chevronDown), attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 16), NSForegroundColorAttributeName: PaperColor.Gray800])
    
    fileprivate let backButton = ASButtonNode()
    fileprivate let backgroundNode = ASDisplayNode()
    fileprivate let titleTextNode = ASTextNode()
    
    var title: String? {
        didSet {
            setupTitleNode()
        }
    }
    
    weak var delegate: OrderNavbarDelegate?
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupBackgroundNode()
        setupBackButtonNode()
        setupTitleNode()
    }
    
    private func setupTitleNode() {
        guard let title = title else {
            return
        }
        
        titleTextNode.attributedText = NSAttributedString(string: title, attributes: [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)
            ])
    }
    
    private func setupBackButtonNode() {
        backButton.setAttributedTitle(dismissIconString, for: .normal)
        backButton.setTargetClosure { [unowned self] _ in
            self.delegate?.orderNavbarDidTapBackButton(node: self)
        }
    }
    
    private func setupBackgroundNode() {
        backgroundNode.backgroundColor = PaperColor.White.withAlphaComponent(0.93)
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
        
        let titleLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(36, 0, 0, 0), child: titleTextNode)
        
        let titleRow = ASStackLayoutSpec.horizontal()
        titleRow.alignItems = .start
        titleRow.justifyContent = .center
        titleRow.children = [titleLayout]
        
        let backgroundRow = ASStackLayoutSpec.horizontal()
        backgroundNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 72)
        backgroundRow.children = [backgroundNode]
        
        return ASOverlayLayoutSpec(child: ASOverlayLayoutSpec(child: backgroundRow, overlay: titleRow), overlay: backButtonRow)
    }
}
