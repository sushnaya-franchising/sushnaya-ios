//
//  AddressContentNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 8/21/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class EditAddressContentNode : ASDisplayNode {
    let navbarNode = EditAddressNavbarNode()
    let pagerNode = ASPagerNode()
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.pagerNode.allowsAutomaticInsetsAdjustment = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASOverlayLayoutSpec(child: self.pagerNode, overlay: self.navbarNode)                    
    }
}
