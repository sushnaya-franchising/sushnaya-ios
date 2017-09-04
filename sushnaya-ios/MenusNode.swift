//
// Created by Igor Kurylenko on 3/30/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol MenusNodeDelegate: class {
    func menusNode(_ node: MenusNode, didSelectMenu menu: MenuDto)
}

class MenusNode: ASDisplayNode {

    var menus: [MenuDto]

    fileprivate var headerTextNode = ASTextNode()
    fileprivate var subheadingTextNode = ASTextNode()
    fileprivate var tableNode = ASTableNode()

    weak var delegate: MenusNodeDelegate?
    
    lazy var headerStringAttributes: [String: AnyObject] = {
        return [
                NSForegroundColorAttributeName: PaperColor.Gray800,
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)
        ]
    }()

    lazy var subheadingStringAttributes: [String: AnyObject] = {
        return [
                NSForegroundColorAttributeName: PaperColor.Gray500,
                NSFontAttributeName: UIFont.systemFont(ofSize: 14)
        ]
    }()

    init(menus: [MenuDto]) {
        self.menus = menus
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
        headerTextNode.attributedText = NSAttributedString(string: "Выберите город", attributes: headerStringAttributes)
        subheadingTextNode.attributedText = NSAttributedString(string: "В каком городе вы хотите сделать заказ?", attributes: subheadingStringAttributes)
    }

    private func setupTableNode() {
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.view.separatorStyle = .none
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec.vertical()
        stack.justifyContent = .start
        stack.spacing = 16

        let headerLayout = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 64, left: 64, bottom: 0, right: 64), child: headerTextNode)
        let subheadingLayout = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 64), child: subheadingTextNode)
        tableNode.style.preferredSize = constrainedSize.max

        stack.children = [headerLayout, subheadingLayout, tableNode]
        
        return stack
    }
}

extension MenusNode: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard menus.count > indexPath.row else { return { ASCellNode() } }

        let menuDto = self.menus[indexPath.row]

        return {
            return MenuCellNode(menuDto: menuDto)
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        delegate?.menusNode(self, didSelectMenu: menus[indexPath.row])
    }
}
