//
// Created by Igor Kurylenko on 3/29/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit

class LocalitiesViewController: ASViewController<LocalitiesNode> {

    var localities: [Locality] {
        get {
            return node.localities
        }
    }

    init(localities: [Locality]) {
        super.init(node: LocalitiesNode(localities: localities))

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are not supported")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPath = node.tableNode.indexPathForSelectedRow {
            node.tableNode.deselectRow(at: indexPath, animated: true)
        }
    }
}

