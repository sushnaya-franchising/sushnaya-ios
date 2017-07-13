//
//  CashOptionCellNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 6/9/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit


class CashOptionCellNode: ASCellNode {
    
    fileprivate let text: String
    
    fileprivate let labelTextNode = ASTextNode()
    fileprivate var highlighter = ASDisplayNode()
    
    override var isSelected: Bool {
        didSet {
            highlighter.backgroundColor = isSelected ? PaperColor.White : nil
            labelTextNode.layer.opacity = isSelected ? 1 : 0.5
        }
    }
    
    fileprivate static let LabelStringAttributes:[String: Any] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        return [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14),
            NSParagraphStyleAttributeName : paragraphStyle
        ]
    }()
    
    init(text: String) {
        self.text = text
        
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = PaperColor.Gray200
        self.highlighter.backgroundColor = nil
        
        setupNodes()
    }
    
    private func setupNodes() {
        labelTextNode.attributedText = NSAttributedString(string: text, attributes: CashOptionCellNode.LabelStringAttributes)
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
