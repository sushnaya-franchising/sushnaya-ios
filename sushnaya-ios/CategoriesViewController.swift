//
//  CategoriesViewController.swift
//  Food
//
//  Created by Igor Kurylenko on 3/30/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class CategoriesViewController: ASViewController<ASTableNode> {
    convenience init() {
        self.init(node: ASTableNode())
        
        node.backgroundColor = PaperColor.Gray200
        //node.view.separatorStyle = .none
    }
}
