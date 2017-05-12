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
    let field1 = FormFieldNode(label: "First")
    let field2 = FormFieldNode(label: "Second")
    var started: Bool = false
    
    convenience init() {
        self.init(node: ASDisplayNode())
        
        self.node.backgroundColor = PaperColor.White
        self.node.automaticallyManagesSubnodes = true
        
        self.node.layoutSpecBlock = { [unowned self] (node, constrainedSize) in
            let layout = ASStackLayoutSpec.vertical()
            layout.children = [self.field1, self.field2]
            
            return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(40, 0, 0, 0), child: layout)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !started && self.field1.isNodeLoaded {
            let origin = self.field1.view.frame.origin
            let size = self.field1.view.bounds.size
            
            addDropdownNodeAsync(containerRect: CGRect(origin: CGPoint(x: 0, y: origin.y + size.height), size: CGSize(width: size.width, height: 80)))
            
            started = true
        }
    }
    
    private func createDropdownNode(containerRect: CGRect) -> ASDisplayNode {
        let dropdown = ASDisplayNode()
        dropdown.backgroundColor = PaperColor.Gray100.withAlphaComponent(0.5)
        dropdown.style.preferredSize = containerRect.size
        dropdown.layoutThatFits(ASSizeRange(min: CGSize.zero, max: containerRect.size))
        dropdown.frame = containerRect
        
        return dropdown
    }
    
    private func addDropdownNodeAsync(containerRect: CGRect) {
        DispatchQueue.global().async {
            let dropdownNode = self.createDropdownNode(containerRect: containerRect)
            
            DispatchQueue.main.async {
                self.view.addSubview(dropdownNode.view)
            }
        }
    }
}
