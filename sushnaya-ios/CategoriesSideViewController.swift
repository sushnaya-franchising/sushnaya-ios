//
//  CategoriesSideViewController.swift
//  Food
//
//  Created by Igor Kurylenko on 3/31/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class CategoriesSideViewController: ASViewController<ASDisplayNode> {
    
    lazy var categories: [MenuCategory] = {
        let categories = [
            MenuCategory(title:"Пицца", subtitle: nil, photoUrl: "category_s_0", photoSize: UIImage(named: "category_s_0")?.size),
            MenuCategory(title:"Роллы", subtitle: nil, photoUrl: "category_s_1", photoSize: UIImage(named: "category_s_1")?.size),
            MenuCategory(title:"Супы", subtitle: nil, photoUrl: "category_s_2", photoSize: UIImage(named: "category_s_2")?.size),
            MenuCategory(title:"Салаты", subtitle: nil, photoUrl: "category_s_3", photoSize: UIImage(named: "category_s_3")?.size),
            MenuCategory(title:"Пельмени", subtitle: nil, photoUrl: "category_s_4", photoSize: UIImage(named: "category_s_4")?.size),
            MenuCategory(title:"Напитки", subtitle: nil, photoUrl: "category_s_5", photoSize: UIImage(named: "category_s_5")?.size)
        ]
        
        return categories
    }()
    
    let _tableNode = ASTableNode()
    
    convenience init() {
        self.init(node: ASDisplayNode())
        
        setupTableNode()
        
        node.automaticallyManagesSubnodes = true
        node.backgroundColor = PaperColor.White
        node.layoutSpecBlock = { [unowned self] _ in
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0), child: self._tableNode)
        }
    }
    
    private func setupTableNode() {
        _tableNode.delegate = self
        _tableNode.dataSource = self
        _tableNode.backgroundColor = PaperColor.White
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _tableNode.view.contentInset = UIEdgeInsets(top: 7, left: 0, bottom: 49 + 10, right: 0)
        _tableNode.view.separatorStyle = .none
        _tableNode.view.showsVerticalScrollIndicator = false
    }
}

extension CategoriesSideViewController: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard categories.count > indexPath.row else { return { ASCellNode() } }
        
        let category = self.categories[indexPath.row]
        
        return {
            return CategorySmallCellNode(category: category)
        }
    }
}

