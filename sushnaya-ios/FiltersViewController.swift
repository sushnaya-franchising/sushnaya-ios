//
//  CategoriesSideViewController.swift
//  Food
//
//  Created by Igor Kurylenko on 3/31/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class FiltersViewController: ASViewController<ASDisplayNode>, PaperFoldAsyncView {

    let cellInsets = Constants.DefaultCellLayout.CellInsets
    let titleLabelInsets = Constants.DefaultCellLayout.TitleLabelInsets
    let titleStringAttrs = Constants.DefaultCellLayout.TitleStringAttributes
    let imageSize = Constants.DefaultCellLayout.ImageSize

    lazy var contexts: [DefaultCellContext]? = {
        let categories = [
            MenuCategory(title:"Пицца", subtitle: nil, photoUrl: "category_s_0", photoSize: UIImage(named: "category_s_0")?.size),
            MenuCategory(title:"Роллы", subtitle: nil, photoUrl: "category_s_1", photoSize: UIImage(named: "category_s_1")?.size),
            MenuCategory(title:"Супы", subtitle: nil, photoUrl: "category_s_2", photoSize: UIImage(named: "category_s_2")?.size),
            MenuCategory(title:"Пельмени", subtitle: nil, photoUrl: "category_s_4", photoSize: UIImage(named: "category_s_4")?.size),
            MenuCategory(title:"Салаты", subtitle: nil, photoUrl: "category_s_3", photoSize: UIImage(named: "category_s_3")?.size),
            MenuCategory(title:"Напитки", subtitle: nil, photoUrl: "category_s_5", photoSize: UIImage(named: "category_s_5")?.size)
        ]
        
        return categories.map{ CategoryCellContext($0) }
    }()
    
    var _collectionNode: ASCollectionNode!
    
    var onViewUpdated: (() -> ())?
    
    convenience init() {
        self.init(node: ASDisplayNode())
        
        let layout = OneColumnLayout()
        layout.delegate = self
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

extension FiltersViewController: ASCollectionDelegate, ASCollectionDataSource {
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return contexts?.count ?? 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }    
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        guard let context = contexts?[indexPath.row] else {
            return ASCellNode()
        }
        
        return DefaultCellNode(context: context)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didEndDisplayingItemWith node: ASCellNode) {
        onViewUpdated?()
    }
}

extension FiltersViewController: OneColumnLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let maxWidth = width - (cellInsets.left + cellInsets.right)

        guard imageSize.width < maxWidth else {
            let boundingRect = CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat(MAXFLOAT))
            let rect = AVMakeRect(aspectRatio: imageSize, insideRect: boundingRect)
            
            return rect.height + cellInsets.top
        }

        return imageSize.height + cellInsets.top
    }

    func collectionView(_ collectionView: UICollectionView, heightForTitleAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        guard let title = contexts?[indexPath.item].title else {
            return cellInsets.bottom
        }

        let maxWidth = width - (cellInsets.left + cellInsets.right + titleLabelInsets.left + titleLabelInsets.right)

        return title.computeHeight(attributes: titleStringAttrs, width: maxWidth) +
                titleLabelInsets.top + titleLabelInsets.bottom + cellInsets.bottom
    }
}

class CategoryCellContext: DefaultCellContext {
    override var title: String {
        set {
            category.title = newValue
        }
        
        get {
            return category.title
        }
    }
    
    override var imageSize: CGSize? {
        set {
            category.photoSize = newValue
        }
        
        get{
            return category.photoSize
        }
    }
    
    override var imageUrl: String? {
        set {
            category.photoUrl = newValue
        }
        
        get {
            return category.photoUrl
        }
    }
    
    let category: MenuCategory
    
    init(_ category: MenuCategory) {
        self.category = category
        super.init(title: category.title)
    }
}
