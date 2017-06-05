//
//  OrderFormOptionalSectionNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 5/17/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OrderFormOptionalSectionNode: ASDisplayNode {
    fileprivate var titleTextNode = ASTextNode()
    
    let commentFormFieldNode = FormFieldNode(label: "Комментарий")
    
    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        setupNodes()
    }
    
    private func setupNodes() {
        setupTitleTextNode()
        setupCommentFormFieldNode()
    }
    
    private func setupTitleTextNode() {
        let title = NSAttributedString(string: "Дополнительно".uppercased(), attributes: OrderWithDeliveryFormNode.SectionTitleStringAttributes)
        titleTextNode.attributedText = title
    }
    
    private func setupCommentFormFieldNode() {
        commentFormFieldNode.returnKeyType = .done
        commentFormFieldNode.onReturn = { [unowned self] in
            self.commentFormFieldNode.resignFirstResponder()
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let titleLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 16, 0, 0), child: titleTextNode)
        let commentFieldLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(4, 16, 0, 16), child: commentFormFieldNode)
        let stackLayout = ASStackLayoutSpec.vertical()
        stackLayout.children = [titleLayout, commentFieldLayout]
        
        return stackLayout
    }
}
