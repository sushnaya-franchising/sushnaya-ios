//
//  OrderFormAddressSectionNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 5/17/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OrderFormAddressSectionNode: ASDisplayNode {
    
    fileprivate var titleTextNode = ASTextNode()
    fileprivate let collectionNode: PageableCollectionNode
    fileprivate let flowLayout: UICollectionViewFlowLayout
    
    var addresses: [Address]? {
        didSet {
            DispatchQueue.main.async { [unowned self] _ in
                self.collectionNode.reloadData()
            }
        }
    }
    
    override init() {
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = OrderFormAddressSectionNode.calcAddressCellSize()
        flowLayout.minimumInteritemSpacing = 8
        
        collectionNode = PageableCollectionNode(collectionViewLayout: flowLayout)
        
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupTitleTextNode()
        setupCollectionNode()
    }
    
    private func setupTitleTextNode() {
        let title = NSAttributedString(string: "Адрес доставки".uppercased(),
                                       attributes: OrderWithDeliveryFormNode.SectionTitleStringAttributes)
        titleTextNode.attributedText = title
    }
    
    private func setupCollectionNode() {
        collectionNode.delegate = self
        collectionNode.dataSource = self
        collectionNode.allowsSelection = true
    }
    
    override func didLoad() {
        super.didLoad()
        
        collectionNode.collectionView.showsHorizontalScrollIndicator = false
        collectionNode.collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let titleLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 16, 0, 0), child: titleTextNode)
        
        let collectionNodeSize = CGSize(width: constrainedSize.max.width, height: flowLayout.itemSize.height)
        collectionNode.style.preferredSize = collectionNodeSize
        
        let stackLayout = ASStackLayoutSpec.vertical()
        stackLayout.spacing = 24
        stackLayout.children = [titleLayout, collectionNode]
        
        return stackLayout
    }
}

extension OrderFormAddressSectionNode: PageableCollectionDataSource, PageableCollectionDelegate {
    func pageableCollectionNode(_ node: PageableCollectionNode, numberOfPagesInSection section: Int) -> Int {
        return (addresses?.count ?? 0) + 1 + 5 // todo: remove +5
    }
    
    func pageableCollectionNode(_ node: PageableCollectionNode, nodeBlockForPageAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { [unowned self] _ in
            guard indexPath.row < (self.addresses?.count ?? 0) + 5 else { // todo: remove +5
                let cell = AddAddressCellNode()
                cell.delegate = self
                return cell
            }
            
            return AddressCellNode(address: self.addresses![0/*indexPath.row*/]) // todo: remove 0, uncomment valid index
        }
    }
    
    func pageableCollectionNode(_ node: PageableCollectionNode, didSelectPageAt indexPath: IndexPath) {
        let pageNode = node.pageForItem(at: indexPath)
        pageNode?.invalidateCalculatedLayout()
        pageNode?.setNeedsDisplay()
    }
}

extension OrderFormAddressSectionNode {
    static func calcAddressCellSize() -> CGSize {
        let screenBounds = UIScreen.main.bounds
        let width = screenBounds.width / Constants.GoldenRatio
        let height = width / Constants.GoldenRatio
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
}

extension OrderFormAddressSectionNode: AddAddressCellNodeDelegate {
    
}
