//
// Created by Igor Kurylenko on 3/29/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit

class MenusViewController: ASViewController<MenusNode> {

    var menus: [Menu] {
        get {
            return node.menus
        }
    }
    
    convenience init(menus: [Menu]) {
        self.init(node: MenusNode(menus: menus))
        
        self.node.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPath = node.tableNode.indexPathForSelectedRow {
            node.tableNode.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension MenusViewController: MenusNodeDelegate {
    func menusNode(_ node: MenusNode, didSelectMenu menu: Menu) {
        DidSelectMenuEvent.fire(menu: menu)
        
        self.dismiss(animated: true, completion: nil)
    }
}