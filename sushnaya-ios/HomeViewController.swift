//
//  HomeNodeController.swift
//  Food
//
//  Created by Igor Kurylenko on 3/27/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import FontAwesome_swift

class HomeViewController: ASViewController<ASDisplayNode> {

    let cellInsets = Constants.ProductCellLayout.CellInsets
    let titleLabelInsets = Constants.ProductCellLayout.TitleLabelInsets
    let subtitleLabelInsets = Constants.ProductCellLayout.SubtitleLabelInsets
    let priceLabelInsets = Constants.ProductCellLayout.PriceLabelInsets
    let titleStringAttrs = Constants.ProductCellLayout.TitleStringAttributes
    let subtitleStringAttrs = Constants.ProductCellLayout.SubtitleStringAttributes

    var products: [Product]?

    var _collectionNode: ASCollectionNode!

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
        let layout = ProductsMosaicLayout()
        layout.delegate = self

        _collectionNode = ASCollectionNode(frame: CGRect.zero, collectionViewLayout: layout)
        _collectionNode.delegate = self
        _collectionNode.dataSource = self
    }

    private func initFakeData() {
        products = []
        for idx in 0..<6 {
            let title = "Роллы с беконом и авокадо"
            let subtitle = "Пикантный насыщенный вкус идеально подходит для зимней погоды"
            let photoUrl = "product_\(idx)"
            let photoSize = UIImage(named: photoUrl)?.size
            let product = Product(title: title, price: 499.99, currencyLocale: "ru_RU", subtitle: subtitle, photoUrl: photoUrl, photoSize: photoSize)

            products?.append(product)
        }
    }

    deinit {
        _collectionNode.delegate = nil
        _collectionNode.dataSource = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        _collectionNode.view.isScrollEnabled = true
        _collectionNode.view.showsVerticalScrollIndicator = false
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        _collectionNode.view.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 49 + 16, right: 0)
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

extension HomeViewController: ASCollectionDataSource, ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return products?.count ?? 0
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        guard let product = products?[indexPath.row] else {
            return ASCellNode()
        }

        return ProductCellNode(product: product)
    }        
}

extension HomeViewController: ProductsMosaicLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let maxWidth = width - (cellInsets.left + cellInsets.right)

        guard let photoSize = products?[indexPath.item].photoSize else {
            return cellInsets.top + (maxWidth) * Constants.GoldenRatio
        }

        let boundingRect = CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRect(aspectRatio: photoSize, insideRect: boundingRect)

        return cellInsets.top + rect.size.height
    }

    func collectionView(_ collectionView: UICollectionView, heightForTitleAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        guard let title = products?[indexPath.item].title else {
            return 0
        }

        let maxWidth = width - (cellInsets.left + cellInsets.right + titleLabelInsets.left + titleLabelInsets.right)

        return title.computeHeight(attributes: titleStringAttrs, width: maxWidth) +
                titleLabelInsets.top + titleLabelInsets.bottom
    }

    func collectionView(_ collectionView: UICollectionView, heightForSubtitleAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        guard let subtitle = products?[indexPath.item].subtitle else {
            return 0
        }

        let maxWidth = width - (cellInsets.left + cellInsets.right + subtitleLabelInsets.left + subtitleLabelInsets.right)

        return subtitle.computeHeight(attributes: subtitleStringAttrs, width: maxWidth) +
                subtitleLabelInsets.top + subtitleLabelInsets.bottom
    }

    func collectionView(_ collectionView: UICollectionView, heightForPriceAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        guard let price = products?[indexPath.item].formattedPrice else {
            return cellInsets.bottom
        }

        let maxWidth = width - (cellInsets.left + cellInsets.right + priceLabelInsets.left + priceLabelInsets.right)

        return price.computeHeight(attributes: titleStringAttrs, width: maxWidth) +
                priceLabelInsets.top + priceLabelInsets.bottom + cellInsets.bottom
    }

}
