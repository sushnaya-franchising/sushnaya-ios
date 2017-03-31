//
//  CategoriesSideViewController.swift
//  Food
//
//  Created by Igor Kurylenko on 3/31/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class CategoriesSideViewController: ASViewController<ASTableNode> {
    convenience init() {
        self.init(node: ASTableNode())
        
        node.backgroundColor = PaperColor.Gray100
        //node.view.separatorStyle = .none
    }
}
