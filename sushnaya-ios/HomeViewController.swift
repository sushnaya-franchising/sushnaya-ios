//
//  HomeNodeController.swift
//  Food
//
//  Created by Igor Kurylenko on 3/27/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class HomeViewController: ASViewController<ASDisplayNode> {
    
    var products: [Product]?

    convenience init() {
        self.init(node: ASDisplayNode())
        
        node.automaticallyManagesSubnodes = true
        node.backgroundColor = PaperColor.White
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)

        if self.products == nil {
            AskMenuEvent.fire()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        fireFakeChangeLoalitiesProposal()
    }
}
