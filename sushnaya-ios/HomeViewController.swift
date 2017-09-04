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
import pop
import PaperFold
import SwiftEventBus

class HomeViewController: ASViewController<ASDisplayNode> {

    private let isFakeMode = false
    
    let cellInsets = Constants.ProductCellLayout.CellInsets
    let titleLabelInsets = Constants.ProductCellLayout.TitleLabelInsets
    let subtitleLabelInsets = Constants.ProductCellLayout.SubtitleLabelInsets
    let pricingInsets = Constants.ProductCellLayout.PricingInsets
    let modifierInsets = Constants.ProductCellLayout.ModifierTextInsets
    let priceButtonInsets = Constants.ProductCellLayout.PriceButtonInsets
    let priceButtonContentInsets = Constants.ProductCellLayout.PriceButtonContentInsets
    let titleStringAttrs = Constants.ProductCellLayout.TitleStringAttributes
    let subtitleStringAttrs = Constants.ProductCellLayout.SubtitleStringAttributes
    let priceStringAttrs = Constants.ProductCellLayout.PriceStringAttributes
    let priceWithModifierStringAttrs = Constants.ProductCellLayout.PriceWithModifierStringAttributes
    let modifierStringAttrs = Constants.ProductCellLayout.PriceModifierStringAttributes

    var products: [Product]?

    var _collectionNode: ASCollectionNode!
    var _selectedProductIndexPath: IndexPath?
    
    
    convenience init() {
        self.init(node: ASDisplayNode())

        setupCollectionNode()

        self.node.automaticallyManagesSubnodes = true
        self.node.backgroundColor = PaperColor.White
        self.node.layoutSpecBlock = { [unowned self] _ in
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0), child: self._collectionNode)
        }                        
        
        SwiftEventBus.onMainThread(self, name: DidOpenConnectionEvent.name) { [unowned self] (notification) in
            if self.products == nil {
                GetMenuEvent.fire()
            }
        }
        
        if isFakeMode {
            initFakeData()
        }
    }
    
    private func setupCollectionNode() {
        let layout = ProductsMosaicLayout()
        layout.delegate = self

        _collectionNode = ASCollectionNode(frame: CGRect.zero, collectionViewLayout: layout)
        _collectionNode.delegate = self
        _collectionNode.dataSource = self
    }

    private func initFakeData() {
//        products = []
//        let titles = [
//            "C беконом и авокадо",
//            "Белый самурай",
//            "С креветками и авокадо",
//            "Четыре сыра",
//            "Пепперони",
//            "С грибами"
//        ]
//        let subtitles = [
//            "Бекон, авокадо, рис, нори",
//            "Креветка, кунжут, рис, нори, сыр филадельфия",
//            "Авокадо, креветка, сыр филадельфия, нори",
//            "Сыр дор блю, пармезан, моцарелла, копченый сыр",
//            "Салями, моцарелла",
//            "Грибы, моцарелла, томаты"
//        ]
//        let categories = ["Роллы", "Пицца"]
//        for idx in 0..<6 {
//            let photoUrl = "product_\(idx)"
//            let photoSize = UIImage(named: photoUrl)?.size
//            var pricing = [Price] ()
//            var category: MenuCategory!
//            
//            if idx < 3 {
//                pricing.append(Price(value: 120, currencyLocale: "ru_RU", modifierName: "3 шт."))
//                pricing.append(Price(value: 240, currencyLocale: "ru_RU", modifierName: "6 шт."))
//                pricing.append(Price(value: 360, currencyLocale: "ru_RU", modifierName: "9 шт."))
//                
//            } else {
//                pricing.append(Price(value: 240, currencyLocale: "ru_RU"))
//            }
//            
//            category = MenuCategory(title: categories[idx < 3 ? 0 : 1])
//
//            let product = Product(title: titles[idx], pricing: pricing, category: category,
//                                  subtitle: subtitles[idx], photoUrl: photoUrl, photoSize: photoSize)
//
//            products?.append(product)
//        }
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

        if products == nil && app.isWebsocketConnected {
            GetMenuEvent.fire()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SwiftEventBus.unregister(self)
    }
}

extension HomeViewController: ProductCellNodeDelegate {
    func productCellNode(_ node: ProductCellNode, didSelectProduct product: Product, withPrice price: Price) {
        AddToCartEvent.fire(product: product, withPrice: price)
    }
}

extension HomeViewController: ASCollectionDataSource, ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return products?.count ?? 0
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard let product = products?[indexPath.row] else {
            return { ASCellNode() }
        }
        
        return { [unowned self] _ in
            let cellNode = ProductCellNode(product: product)
            cellNode.delegate = self
            return cellNode
        }
    }
}

extension HomeViewController: ProductsMosaicLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let maxWidth = width - (cellInsets.left + cellInsets.right)

        guard let imageSize = products?[indexPath.item].imageSize else {
            return cellInsets.top + (maxWidth) * Constants.GoldenRatio
        }

        let boundingRect = CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRect(aspectRatio: imageSize, insideRect: boundingRect)

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
    
    func collectionView(_ collectionView: UICollectionView, heightForPricingAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let pricing = products![indexPath.item].pricing
        
        let maxWidth = width - (cellInsets.left + cellInsets.right + pricingInsets.left + pricingInsets.right)
        var height:CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for price in pricing {
            let priceStringSize = price.formattedValue.boundingRect(attributes: priceStringAttrs, width: maxWidth)
            let priceButtonSize = CGSize(width: priceStringSize.width + priceButtonContentInsets.left + priceButtonContentInsets.right + priceButtonInsets.left + priceButtonInsets.right,
                                         height: priceStringSize.height + priceButtonContentInsets.top + priceButtonContentInsets.bottom + priceButtonInsets.top + priceButtonInsets.bottom)
            
            var modifierLabelHeight:CGFloat = 0
            if let modifierName = price.modifierName {
                let modifierStringHeight = modifierName.computeHeight(attributes: modifierStringAttrs, width: maxWidth - priceButtonSize.width)
                modifierLabelHeight = modifierInsets.top + modifierStringHeight + modifierInsets.bottom
            }
            
            rowHeight = (modifierLabelHeight > priceButtonSize.height ?
                modifierLabelHeight: priceButtonSize.height)
            
            height = height + rowHeight + (height == 0 ? 0 : Constants.ProductCellLayout.PricingRowSpacing)
        }
        
        return pricingInsets.top + height + pricingInsets.bottom + cellInsets.bottom
    }
}
