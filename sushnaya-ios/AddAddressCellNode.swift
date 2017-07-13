//
//  AddAddressCellNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 7/1/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol AddAddressCellNodeDelegate: class {
    
}

class AddAddressCellNode: ASCellNode {
    fileprivate let plusIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .plus), attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 16), NSForegroundColorAttributeName: PaperColor.Gray800])
    fileprivate let labelTextNode = ASTextNode()
    fileprivate var highlighter = ASDisplayNode()
    
    weak var delegate: AddAddressCellNodeDelegate?
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = PaperColor.Gray200
        self.highlighter.backgroundColor = nil
        
        setupNodes()
    }
    
    private func setupNodes() {
        labelTextNode.attributedText = plusIconString
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.cornerRadius = 11
        self.clipsToBounds = true
        
        highlighter.cornerRadius = max(self.cornerRadius - 1, 0)
        highlighter.clipsToBounds = true
        
        if(!self.isSelected) {
            self.labelTextNode.layer.opacity = 0.5
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let labelLayout = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [],
                                             child: ASInsetLayoutSpec(insets: UIEdgeInsetsMake(4, 8, 4, 8), child: labelTextNode))
        
        highlighter.style.preferredSize = CGSize(width: constrainedSize.max.width - 4, height: constrainedSize.max.height - 4)
        let highlighterLayout = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: highlighter)
        
        return ASOverlayLayoutSpec(child: highlighterLayout, overlay: labelLayout)
    }
}
