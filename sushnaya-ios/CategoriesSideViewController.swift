//
//  CategoriesSideViewController.swift
//  Food
//
//  Created by Igor Kurylenko on 3/31/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class CategoriesSideViewController: ASViewController<ASDisplayNode>, PaperFoldAsyncView {
    
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
    
    var _collectionNode: ASCollectionNode!
    
    var onViewUpdated: (() -> ())?
    
    convenience init() {
        self.init(node: ASDisplayNode())
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        _collectionNode = ASCollectionNode(collectionViewLayout: layout)
        
        setupTableNode()
        
        node.automaticallyManagesSubnodes = true
        node.backgroundColor = PaperColor.White
        node.layoutSpecBlock = { [unowned self] _ in
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0), child: self._collectionNode)
        }
    }
    
    private func setupTableNode() {
        _collectionNode.delegate = self
        _collectionNode.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _collectionNode.view.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 49 + 10, right: 0)
        _collectionNode.view.showsVerticalScrollIndicator = false
    }
}

extension CategoriesSideViewController: ASCollectionDelegate, ASCollectionDataSource {
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }    
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let category = categories[indexPath.row]
        
        return CategorySmallCellNode(category: category)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didEndDisplayingItemWith node: ASCellNode) {
        onViewUpdated?()
    }
}
