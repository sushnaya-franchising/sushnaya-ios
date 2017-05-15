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
        
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {        
        self.view.endEditing(true)
    }
}
