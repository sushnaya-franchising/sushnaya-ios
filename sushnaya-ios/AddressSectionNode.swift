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
    fileprivate let collectionNode: ASCollectionNode
    
    var addresses: [Address]? {
        didSet {
            DispatchQueue.main.async { [unowned self] _ in
                self.collectionNode.reloadData()
            }
        }
    }
    
    override init() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 230, height: 115)
        flowLayout.minimumInteritemSpacing = 8
        
        collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        
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
        
        collectionNode.view.showsHorizontalScrollIndicator = false
        collectionNode.view.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let titleLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 16, 0, 0), child: titleTextNode)
        
        let collectionNodeSize = CGSize(width: constrainedSize.max.width, height: 115)
        collectionNode.style.preferredSize = collectionNodeSize
        
        let stackLayout = ASStackLayoutSpec.vertical()
        stackLayout.spacing = 24
        stackLayout.children = [titleLayout, collectionNode]
        
        return stackLayout
    }
}

extension OrderFormAddressSectionNode: ASCollectionDataSource, ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return (addresses?.count ?? 0) + 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { [unowned self] _ in
            guard indexPath.row < (self.addresses?.count ?? 0) else {
                let cell = AddAddressCellNode()
                cell.delegate = self
                return cell
            }
            
            return AddressCellNode(address: self.addresses![indexPath.row])
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let node = collectionNode.nodeForItem(at: indexPath)
        node?.invalidateCalculatedLayout()
        node?.setNeedsDisplay()
    }
}

extension OrderFormAddressSectionNode: AddAddressCellNodeDelegate {
    
}
