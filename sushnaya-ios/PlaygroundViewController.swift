//
//  PlaygroundViewController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 5/9/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PlaygroundViewController: ASViewController<ASDisplayNode> {
    
    var playgroundContentNode = PlaygroundContentNode(v: "OK")
    
    convenience init() {        
        self.init(node: ASDisplayNode())
        
        self.node.automaticallyManagesSubnodes = true
        
        self.node.layoutSpecBlock = { [unowned self] (node, constrainedSize) in
            let frontLayout = ASStackLayoutSpec.vertical()
            frontLayout.style.preferredSize = constrainedSize.max
            
            let frontPusher = ASLayoutSpec()
            let frontPusherHeight: CGFloat = 78
            frontPusher.style.height = ASDimension(unit: .points, value: frontPusherHeight)
            
            let contentSize = CGSize(width: constrainedSize.max.width,
                                     height: constrainedSize.max.height - frontPusherHeight)
            let contentLayout = self.contentLayoutSpecThatFits(ASSizeRange(min: contentSize, max: contentSize))
            
            frontLayout.children = [frontPusher, contentLayout]
            
            return frontLayout
        }
        
        
    }
    
    func contentLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        playgroundContentNode.style.preferredSize = constrainedSize.max
        
        return ASWrapperLayoutSpec(layoutElement: playgroundContentNode)
    }
}

class PlaygroundContentNode: ASDisplayNode {
    init(v: String) {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = PaperColor.White
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 3
    }
}
