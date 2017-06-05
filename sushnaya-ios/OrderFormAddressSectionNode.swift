//
//  OrderFormAddressSectionNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 5/17/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OrderFormAddressSectionNode: ASDisplayNode {
    fileprivate var titleTextNode = ASTextNode()
    fileprivate var fakeNode = ASDisplayNode()
    
    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        setupNodes()
    }
    
    private func setupNodes() {
        setupTitleTextNode()
        setupFakeNode()
    }
    
    private func setupFakeNode() {
        fakeNode.backgroundColor = PaperColor.Gray100
    }
    
    private func setupTitleTextNode() {
        let title = NSAttributedString(string: "Адрес доставки".uppercased(), attributes: OrderWithDeliveryFormNode.SectionTitleStringAttributes)
        titleTextNode.attributedText = title
    }
    
    override func didLoad() {
        super.didLoad()
        
        fakeNode.cornerRadius = 11
        fakeNode.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let titleLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 16, 0, 24), child: titleTextNode)
        
        fakeNode.style.flexGrow = 1.0
        fakeNode.style.height = ASDimension(unit: .points, value: 88)
        let fakeLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 16, 0, 16), child: fakeNode)
        
        let stackLayout = ASStackLayoutSpec.vertical()
        stackLayout.spacing = 24
        stackLayout.children = [titleLayout, fakeLayout]
        
        return stackLayout
    }
}
