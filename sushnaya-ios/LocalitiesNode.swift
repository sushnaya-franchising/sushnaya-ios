//
// Created by Igor Kurylenko on 3/30/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class LocalitiesNode: ASDisplayNode {

    var localities: [Locality]

    var headerNode = ASTextNode()
    var subheadingNode = ASTextNode()
    var tableNode = ASTableNode()

    lazy var headerStringAttributes: [String: AnyObject] = {
        return [
                NSForegroundColorAttributeName: PaperColor.Gray600,
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)
        ]
    }()

    lazy var subheadingStringAttributes: [String: AnyObject] = {
        return [
                NSForegroundColorAttributeName: PaperColor.Gray500,
                NSFontAttributeName: UIFont.systemFont(ofSize: 14)
        ]
    }()

    init(localities: [Locality]) {
        self.localities = localities
        super.init()

        self.automaticallyManagesSubnodes = true
        self.backgroundColor = UIColor.white

        setupNodes()
    }

    private func setupNodes() {
        setupHeading()
        setupTableNode()
    }

    private func setupHeading() {
        headerNode.attributedText = NSAttributedString(string: "Выберите город", attributes: headerStringAttributes)
        subheadingNode.attributedText = NSAttributedString(string: "В каком городе вы хотите сделать заказ?", attributes: subheadingStringAttributes)
    }

    private func setupTableNode() {
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.view.separatorStyle = .none
    }


    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec.vertical()
        stack.alignItems = .center
        stack.justifyContent = .start
        stack.spacing = 16

        tableNode.style.flexGrow = 1.0

        stack.children = [headerNode, subheadingNode, tableNode]

        let rowInsets = UIEdgeInsets(top: 44, left: 0, bottom: 16, right: 0)
        return ASInsetLayoutSpec(insets: rowInsets, child: stack)
    }
}

extension LocalitiesNode: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return localities.count
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard localities.count > indexPath.row else { return { ASCellNode() } }

        let locality = self.localities[indexPath.row]

        return {
            return LocalityCellNode(locality: locality)
        }
    }
}
