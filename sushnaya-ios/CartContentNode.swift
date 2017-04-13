//
//  CartContentNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/13/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class CartContentNode: ASDisplayNode {
    
    let cart: Cart
    
    init(cart: Cart) {
        self.cart = cart
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = PaperColor.White
    }
}
