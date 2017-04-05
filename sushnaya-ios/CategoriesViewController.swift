//
//  CategoriesViewController.swift
//  Food
//
//  Created by Igor Kurylenko on 3/30/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class CategoriesViewController: ASViewController<ASDisplayNode> {
    
    var categories: [MenuCategory]?
    
    let kNumberOfСategories: UInt = 6
    var _collectionNode: ASCollectionNode!
    
    convenience init() {
        self.init(node: ASDisplayNode())
        
        setupCollectionNode()
        
        node.automaticallyManagesSubnodes = true
        node.backgroundColor = PaperColor.White
        node.layoutSpecBlock = { [unowned self] _ in
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0), child: self._collectionNode)
        }
        
        initFakeData()
    }
    
    private func setupCollectionNode() {
        let layout = CategoriesMosaicCollectionViewLayout()
        layout.delegate = self
        
        _collectionNode = ASCollectionNode(frame: CGRect.zero, collectionViewLayout: layout)
        _collectionNode.delegate = self
        _collectionNode.dataSource = self
    }
    
    private func initFakeData() {
        categories = []
        for idx in 0 ..< kNumberOfСategories {
            let title = "Раздел \(idx)"
            let subtitle = "Описание раздела \(idx)"
            let photoUrl = "category_\(idx)"
            let photosize = UIImage(named: photoUrl)?.size
            let category = MenuCategory(title: title, subtitle: subtitle, photoUrl: photoUrl, photoSize: photosize)
            
            categories?.append(category)
        }
    }
    
    deinit {
        _collectionNode.delegate = nil
        _collectionNode.dataSource = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _collectionNode.view.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 49 + 10, right: 0)
        _collectionNode.view.isScrollEnabled = true
        _collectionNode.view.showsVerticalScrollIndicator = false
    }
}

extension CategoriesViewController: ASCollectionDataSource, ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        guard let category = categories?[indexPath.row] else {return ASCellNode()}
        
        return CategoryCellNode(category: category)
    }
}

extension CategoriesViewController: MosaicCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let category = categories?[indexPath.item]
        let maxWidth = width - Constants.CategoryCellLayout.CellInsets.left - Constants.CategoryCellLayout.CellInsets.right
        
        if let imageSize = category?.photoSize {
            
            let boundingRect = CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat(MAXFLOAT))
            let rect = AVMakeRect(aspectRatio: imageSize, insideRect: boundingRect)
            
            return Constants.CategoryCellLayout.CellInsets.top +
                rect.size.height
            
        }else {
            return Constants.CategoryCellLayout.CellInsets.top +
                (maxWidth) * Constants.GoldenRatio
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForTitleAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        if let category = categories?[indexPath.item] {
            let maxWidth = width - Constants.CategoryCellLayout.CellInsets.left - Constants.CategoryCellLayout.CellInsets.right -
                Constants.CategoryCellLayout.TitleLabelInsets.left - Constants.CategoryCellLayout.TitleLabelInsets.right
            return Constants.CategoryCellLayout.TitleLabelInsets.top +
                category.heightForTitle(attributes: Constants.CategoryCellLayout.TitleStringAttributes, width: maxWidth) +
                Constants.CategoryCellLayout.TitleLabelInsets.bottom
            
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForSubtitleAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        if let category = categories?[indexPath.item] {
            let maxWidth = width - Constants.CategoryCellLayout.CellInsets.left - Constants.CategoryCellLayout.CellInsets.right -
            Constants.CategoryCellLayout.SubtitleLabelInsets.left - Constants.CategoryCellLayout.SubtitleLabelInsets.right
            return Constants.CategoryCellLayout.SubtitleLabelInsets.top +
                category.heightForSubtitle(attributes: Constants.CategoryCellLayout.SubtitleStringAttributes, width: maxWidth) +
            Constants.CategoryCellLayout.SubtitleLabelInsets.bottom +
            Constants.CategoryCellLayout.CellInsets.bottom
            
        } else {
            return 0
        }
    }
}
