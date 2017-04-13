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
    
    var _cartNode: CartNode!
    
    var cart: Cart {
        return app.userSession.cart
    }
    
    convenience init() {
        self.init(node: ASDisplayNode())
        
        setupCartNode()
        
        self.node.automaticallyManagesSubnodes = true
        self.node.layoutSpecBlock = { [unowned self] _ in
            return ASWrapperLayoutSpec(layoutElement: self._cartNode)
        }
    }
    
    private func setupCartNode() {
        _cartNode = CartNode(cart: cart)
        _cartNode.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
}

extension CartViewController: CartNodeDelegate {
    func cartNodeDidTouchUpInsideCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
