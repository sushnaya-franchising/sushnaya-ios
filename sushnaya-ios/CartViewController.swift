//
//  CartViewController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/7/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class CartViewController: ASViewController<ASDisplayNode> {
    
    let button = ASButtonNode()
    
    convenience init() {
        self.init(node: ASDisplayNode())
        
        node.backgroundColor = PaperColor.Gray200
        
        button.setAttributedTitle(NSAttributedString.attributedString(string: "Close", fontSize: 17, color: PaperColor.Gray800), for: .normal)
        button.addTarget(self, action: #selector(close), forControlEvents: .touchUpInside)
        
        node.automaticallyManagesSubnodes = true
        node.layoutSpecBlock = { [unowned self] _ in
            return ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: self.button)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
