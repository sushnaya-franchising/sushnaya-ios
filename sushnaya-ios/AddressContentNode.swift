//
//  AddressContentNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 8/21/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class AddressContentNode : ASDisplayNode {
    let navbarNode = AddressNavbarNode()
    let pagerNode = ASPagerNode()
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.pagerNode.allowsAutomaticInsetsAdjustment = true
    }
    
    override func didLoad() {
        super.didLoad()
        
//        layer.shadowOffset = CGSize(width: 0, height: 0)
//        layer.shadowOpacity = 0.3
//        layer.shadowRadius = 3
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASOverlayLayoutSpec(child: self.pagerNode, overlay: self.navbarNode)                    
    }
}
