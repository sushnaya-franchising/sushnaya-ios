//
//  CartToolBarNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/16/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import FontAwesome_swift

class CartToolBarNode: ASDisplayNode {
    
    let cart: Cart
    
    let sumTextNode = ASTextNode()
    let deliveryButton = ASButtonNode()
    let changeOrderTypeButton = ASButtonNode()
    let recommendationsTitleNode = ASTextNode()
    private(set) var recommendationsCollection: ASCollectionNode!
    
    lazy var recommendations: [CellData]? = {
        let categories = [
            MenuCategory(title:"Салаты", subtitle: nil, photoUrl: "category_s_3", photoSize: UIImage(named: "category_s_3")?.size),
            MenuCategory(title:"Напитки", subtitle: nil, photoUrl: "category_s_5", photoSize: UIImage(named: "category_s_5")?.size)
        ]
        
        let giftIconImage = UIImage.fontAwesomeIcon(name: .gift, textColor: PaperColor.Gray800,
                                                    size: CGSize(width: 32, height: 32))
        let giftCellData = CellData(title: "Подарок")
        giftCellData.image = giftIconImage
        
        var recommendations = [giftCellData]
        categories.forEach {
            recommendations.append(CategoryCellData($0))
        }
        
        return recommendations
    }()
    
    lazy var biggestCellHeight:CGFloat = {  [unowned self] in
        var biggestHeight:CGFloat = 0
        
        self.recommendations?.forEach {
            let titleHeight = $0.title.computeHeight(attributes: Constants.FilterCellLayout.TitleStringAttributes,
                                                              width: Constants.FilterCellLayout.ImageSize.width)
            
            let height = Constants.FilterCellLayout.CellInsets.top +
                Constants.FilterCellLayout.ImageSize.height +
                Constants.FilterCellLayout.TitleLabelInsets.top +
                titleHeight +
                Constants.FilterCellLayout.TitleLabelInsets.bottom +
                Constants.FilterCellLayout.CellInsets.bottom
            
            if height >= biggestHeight {
                biggestHeight = height
            }
        }
        
        return biggestHeight
    }()
    
    lazy var recommendedCategoryCellConstrainedSize: ASSizeRange = { [unowned self] in
        let height = self.biggestCellHeight
        let width = Constants.FilterCellLayout.CellInsets.left +
            Constants.FilterCellLayout.ImageSize.width +
            Constants.FilterCellLayout.CellInsets.right
        let size = CGSize(width: width, height: height)
        
        return ASSizeRange(min: size, max: size)
    }()
    
    init(cart: Cart) {
        self.cart = cart
        super.init()
        
        automaticallyManagesSubnodes = true
        backgroundColor = PaperColor.White.withAlphaComponent(0.93)
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupSumTextNode()
        setupDeliveryButton()
        setupChangeOrderTypeButton()
        setupRecommendationsTitleNode()
        setupRecommendationsCollectionNode()
    }
    
    private func setupSumTextNode() {
        sumTextNode.attributedText = NSAttributedString.attributedString(string: "Сумма: \(cart.sum.formattedValue)", fontSize: 14, color: PaperColor.Gray800)
    }
    
    private func setupDeliveryButton() {
        let title = NSAttributedString(string: "Доставить", attributes: Constants.CartLayout.DeliveryButtonTitileStringAttributes)
        deliveryButton.setAttributedTitle(title, for: .normal)
        deliveryButton.backgroundColor = Constants.CartLayout.DeliveryButtonBackgroundColor
    }
    
    private func setupChangeOrderTypeButton() {
        let title = NSAttributedString(string: String.fontAwesomeIcon(name: .ellipsisH), attributes: [
            NSFontAttributeName: UIFont.fontAwesome(ofSize: 16),
            NSForegroundColorAttributeName: PaperColor.Gray800
        ])
        changeOrderTypeButton.setAttributedTitle(title, for: .normal)
        changeOrderTypeButton.backgroundColor = Constants.CartLayout.DeliveryButtonBackgroundColor
    }
    
    private func setupRecommendationsCollectionNode() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        let recommendationsCollection = ASCollectionNode(collectionViewLayout: flowLayout)
        self.recommendationsCollection = recommendationsCollection
        recommendationsCollection.dataSource = self
        recommendationsCollection.delegate = self
        recommendationsCollection.backgroundColor = PaperColor.White.withAlphaComponent(0)
        recommendationsCollection.allowsSelection = false
    }
    
    private func setupRecommendationsTitleNode() {
        let title = NSAttributedString(string: "Добавьте дополнительно".uppercased(),
                           attributes: Constants.CartLayout.SectionTitleStringAttributes)
        recommendationsTitleNode.attributedText = title
    }
    
    override func didLoad() {
        super.didLoad()
        
        deliveryButton.cornerRadius = 10
        deliveryButton.clipsToBounds = true
        
        changeOrderTypeButton.cornerRadius = 10
        changeOrderTypeButton.clipsToBounds = true
        
        recommendationsCollection.view.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let sumTextNodeLayout = sumLayoutSpecThatFits(constrainedSize)
        let deliveryButtonLayout = deliveryButtonLayoutSpecThatFits(constrainedSize)
        let recommendationsTitleLayout = recommendationsTitlLayoutSpecThatFits(constrainedSize)
        
        recommendationsCollection.style.preferredSize = CGSize(width: constrainedSize.max.width, height: biggestCellHeight)
        
        let layout = ASStackLayoutSpec.vertical()        
        layout.alignItems = .center
        layout.children = [recommendationsTitleLayout, recommendationsCollection,
                           sumTextNodeLayout, deliveryButtonLayout]
        return layout
    }
    
    private func sumLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 56), child: sumTextNode)
        layout.style.alignSelf = .end
        
        return layout
    }
    
    private func deliveryButtonLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let substrate = substrateLayout()
        
        changeOrderTypeButton.style.preferredSize = CGSize(width: 44, height: 44)
        deliveryButton.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 44)
        
        let insets = UIEdgeInsets(top: 0, left: CGFloat.infinity, bottom: 0, right: 0)
        let substrateInsetLayout = ASInsetLayoutSpec(insets: insets, child: substrate)
        let substrateOverDeliveryButton = ASOverlayLayoutSpec(child: deliveryButton, overlay: substrateInsetLayout)
        
        let changeOrderTypeButtonInsetLayout = ASInsetLayoutSpec(insets: insets, child: changeOrderTypeButton)
        let changeOrderTypeButtonOverDeliveryButton = ASOverlayLayoutSpec(child: substrateOverDeliveryButton,
                                                                          overlay: changeOrderTypeButtonInsetLayout)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
                                 child: changeOrderTypeButtonOverDeliveryButton)
    }
    
    private func substrateLayout() -> ASLayoutSpec {
        let substrate = ASDisplayNode()
        substrate.backgroundColor = PaperColor.White
        substrate.style.preferredSize = CGSize(width: 45, height: 44)
        
        let colorSubstrate = ASDisplayNode()
        colorSubstrate.backgroundColor = changeOrderTypeButton.backgroundColor
        colorSubstrate.style.preferredSize = CGSize(width: 22, height: 44)
        
        return ASOverlayLayoutSpec(child: substrate, overlay: ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 22), child: colorSubstrate))
    }
    
    private func recommendationsTitlLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 16, bottom: 10, right: 0),
                                                           child: recommendationsTitleNode)
        layout.style.alignSelf = .start
        
        return layout
    }
}

extension CartToolBarNode: ASCollectionDataSource, ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard let recommendation = recommendations?[indexPath.item] else {
            return {
                ASCellNode()
            }
        }
        
        return {
            let cell = FilterCellNode(filter: recommendation)
            cell.backgroundColor = PaperColor.White.withAlphaComponent(0)
            
            return cell
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return recommendations?.count ?? 0
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        return recommendedCategoryCellConstrainedSize
    }
}
