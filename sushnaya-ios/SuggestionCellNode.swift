//
//  SuggestionCellNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 5/4/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class SuggestionCellNode: ASCellNode {
    
    let suggestion: String
    
    let suggesionTextNode = ASTextNode()
    
    override var isSelected: Bool {
        didSet {
            guard isSelected else {
                return
            }
            
            self.backgroundColor = PaperColor.White
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            guard isHighlighted else {
                return
            }
            
            self.backgroundColor = PaperColor.White
        }
    }
    
    init(suggestion: String) {
        self.suggestion = suggestion
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupSuggestionTextNode()
    }
    
    private func setupSuggestionTextNode() {
        suggesionTextNode.attributedText = NSAttributedString.attributedString(
            string: suggestion, fontSize: 14, color: PaperColor.Gray800)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let suggestionTextNodeLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 62, 0, 16), child: suggesionTextNode)
        
        let layout = ASStackLayoutSpec.vertical()
        layout.justifyContent = .center
        layout.children = [suggestionTextNodeLayout]
        layout.style.minHeight = ASDimension(unit: .points, value: 44)
        
        return layout
    }
}
