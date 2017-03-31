//
//  HomeNodeController.swift
//  Food
//
//  Created by Igor Kurylenko on 3/27/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class HomeViewController: ASViewController<ASTableNode> {

    var products: [Product]?

    var tableNode: ASTableNode {
        return node
    }

    convenience init() {
        self.init(node: ASTableNode())

//        tableNode.delegate = self
//        tableNode.dataSource = self
        tableNode.view.separatorStyle = .none
        tableNode.backgroundColor = UIColor.white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)

        if self.products == nil {
            AskMenuEvent.fire()
        }
        //fireFakeChangeLoalitiesProposal()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        EventBus.unregister(self)
    }
}

//extension HomeViewController: ASTableDataSource, ASTableDelegate {
//
//}
