//
//  SettingsNodeController.swift
//  Food
//
//  Created by Igor Kurylenko on 3/27/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class SettingsViewController: ASViewController<ASTableNode> {

    var tableNode: ASTableNode {
        return node
    }

    init() {
        super.init(node: ASTableNode())

        tableNode.backgroundColor = UIColor.white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are not supported")
    }
}
