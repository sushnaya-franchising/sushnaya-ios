//
//  OrderWithDeliveryViewController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 5/15/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop

class OrderWithDeliveryViewController: ASViewController<ASDisplayNode> {
    
    fileprivate let navbarNode = OrderNavbarNode()
    
    fileprivate var tapRecognizer: UITapGestureRecognizer!
    
    convenience init() {
        self.init(node: ASDisplayNode())
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))
        tapRecognizer.numberOfTapsRequired = 1
        
        self.node.backgroundColor = PaperColor.White
        self.node.automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    private func setupNodes() {
        self.navbarNode.delegate = self
        
        self.node.layoutSpecBlock = { [unowned self] _ in
            return ASWrapperLayoutSpec(layoutElement: self.navbarNode)
        }
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {        
        self.view.endEditing(true)
    }
}

extension OrderWithDeliveryViewController: OrderNavbarDelegate {
    func orderNavbarDidTapBackButton(node: OrderNavbarNode) {
        self.dismiss(animated: true, completion: nil)
        self.view.endEditing(true)
    }
}
