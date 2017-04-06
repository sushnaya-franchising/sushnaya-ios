//
//  CategoriesViewController.swift
//  Food
//
//  Created by Igor Kurylenko on 3/30/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class CategoriesViewController: ASViewController<ASDisplayNode>, PaperFoldAsyncView {
    
    let cellInsets = Constants.CategoryCellLayout.CellInsets
    let titleLabelInsets = Constants.CategoryCellLayout.TitleLabelInsets
    let subtitleLabelInsets = Constants.CategoryCellLayout.SubtitleLabelInsets
    let titleStringAttrs = Constants.CategoryCellLayout.TitleStringAttributes
    let subtitleStringAttrs = Constants.CategoryCellLayout.SubtitleStringAttributes
    
    var categories: [MenuCategory]?
    
    var _collectionNode: ASCollectionNode!
    
    var onViewUpdated: (() -> ())?
    
    static var _homeTabBarItemSelectedImage: UIImage?
    
    convenience init() {
        self.init(node: ASDisplayNode())                
        
        setupCollectionNode()
        
        self.node.automaticallyManagesSubnodes = true
        self.node.backgroundColor = PaperColor.White
        self.node.layoutSpecBlock = { [unowned self] _ in
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
        for idx in 0 ..< 6 {
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
        guard let category = categories?[indexPath.row] else { return ASCellNode() }
        
        return CategoryCellNode(category: category)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didEndDisplayingItemWith node: ASCellNode) {
        onViewUpdated?()
    }
}

extension CategoriesViewController: CategoriesMosaicCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let maxWidth = width - (cellInsets.left + cellInsets.right)

        guard let imageSize = categories?[indexPath.item].photoSize else {
            return cellInsets.top + (maxWidth) * Constants.GoldenRatio
        }
        
        let boundingRect = CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRect(aspectRatio: imageSize, insideRect: boundingRect)
            
        return cellInsets.top + rect.size.height
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForTitleAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        guard let title = categories?[indexPath.item].title  else { return 0 }
        
        let maxWidth = width - (cellInsets.left + cellInsets.right + titleLabelInsets.left + titleLabelInsets.right)
            
        return title.computeHeight(attributes: titleStringAttrs, width: maxWidth) +
            titleLabelInsets.top + titleLabelInsets.bottom
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForSubtitleAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        guard let subtitle = categories?[indexPath.item].subtitle else { return cellInsets.bottom }
        
        let maxWidth = width - (cellInsets.left + cellInsets.right + subtitleLabelInsets.left + subtitleLabelInsets.right)
        
        return subtitle.computeHeight(attributes: subtitleStringAttrs, width: maxWidth) +
            subtitleLabelInsets.top + subtitleLabelInsets.bottom + cellInsets.bottom
    }
}
