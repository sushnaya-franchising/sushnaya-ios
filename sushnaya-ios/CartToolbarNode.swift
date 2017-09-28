import Foundation
import AsyncDisplayKit
import FontAwesome_swift

class CartToolbarNode: ASDisplayNode {

    let currencyLocale = "ru_RU"
    
    let cart: Cart

    let subtotalTextNode = ASTextNode()
    let orderWithDeliveryButton = ASButtonNode()
    let changeOrderTypeButton = ASButtonNode()
    let recommendationsTitleNode = ASTextNode()
    private(set) var recommendationsCollection: ASCollectionNode!

    lazy var contexts = [DefaultCellContext]()

    lazy var biggestCellHeight: CGFloat = { [unowned self] in
        var biggestHeight: CGFloat = 0

        self.contexts.forEach {
            let titleHeight = $0.title.calculateHeight(attributes: Constants.DefaultCellLayout.TitleStringAttributes,
                    width: Constants.CartLayout.RecommendationImageSize.width)

            let height = Constants.DefaultCellLayout.CellInsets.top +
                    Constants.CartLayout.RecommendationImageSize.height +
                    Constants.DefaultCellLayout.TitleLabelInsets.top +
                    titleHeight +
                    Constants.DefaultCellLayout.TitleLabelInsets.bottom +
                    Constants.DefaultCellLayout.CellInsets.bottom

            if height >= biggestHeight {
                biggestHeight = height
            }
        }

        return biggestHeight
    }()

    lazy var recommendedCategoryCellConstrainedSize: ASSizeRange = { [unowned self] in
        let height = self.biggestCellHeight
        let width = Constants.DefaultCellLayout.CellInsets.left +
                Constants.CartLayout.RecommendationImageSize.width +
                Constants.DefaultCellLayout.CellInsets.right
        let size = CGSize(width: width, height: height)

        return ASSizeRange(min: size, max: size)
    }()

    init(cart: Cart) {
        self.cart = cart
        super.init()

        automaticallyManagesSubnodes = true
        backgroundColor = PaperColor.White.withAlphaComponent(0.93)

        setupNodes()
        registerEventHandlers()
    }

    private func registerEventHandlers() {
        EventBus.onMainThread(self, name: DidAddToCartEvent.name) { [unowned self] _ in
            self.updateSubtotalTextNode()
        }

        EventBus.onMainThread(self, name: DidRemoveFromCartEvent.name) { [unowned self] _ in
            self.updateSubtotalTextNode()
        }
    }

    private func setupNodes() {
        setupSubtotalTextNode()
        setupDeliveryButton()
        setupChangeOrderTypeButton()
        setupRecommendationsTitleNode()
        setupRecommendationsCollectionNode()
    }

    private func setupSubtotalTextNode() {
        updateSubtotalTextNode()
    }

    private func updateSubtotalTextNode() {
        subtotalTextNode.attributedText = NSAttributedString.attributedString(string: "Сумма: \(cart.sum(forCurrencyLocale: currencyLocale))", fontSize: 14, color: PaperColor.Gray800)
//                subtotalTextNode.attributedText = NSAttributedString.attributedString(string: "Сумма: ", fontSize: 14, color: PaperColor.Gray800)
    }

    private func setupDeliveryButton() {
        let title = NSAttributedString(string: "Доставить", attributes: Constants.CartLayout.DeliveryButtonTitileStringAttributes)
        orderWithDeliveryButton.setAttributedTitle(title, for: .normal)
        orderWithDeliveryButton.backgroundColor = Constants.CartLayout.DeliveryButtonBackgroundColor
    }

    private func setupChangeOrderTypeButton() {
        let title = NSAttributedString(string: String.fontAwesomeIcon(name: .ellipsisV), attributes: [
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

        orderWithDeliveryButton.cornerRadius = 11
        orderWithDeliveryButton.clipsToBounds = true

        changeOrderTypeButton.cornerRadius = 11
        changeOrderTypeButton.clipsToBounds = true

        recommendationsCollection.view.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let subtotalTextNodeLayout = sumLayoutSpecThatFits(constrainedSize)
        let deliveryButtonLayout = deliveryButtonLayoutSpecThatFits(constrainedSize)
        let recommendationsTitleLayout = recommendationsTitlLayoutSpecThatFits(constrainedSize)

        recommendationsCollection.style.preferredSize = CGSize(width: constrainedSize.max.width, height: biggestCellHeight)

        let layout = ASStackLayoutSpec.vertical()
        layout.alignItems = .center
        layout.children = [recommendationsTitleLayout, recommendationsCollection,
                           subtotalTextNodeLayout, deliveryButtonLayout]
        return layout
    }

    private func sumLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 56), child: subtotalTextNode)
        layout.style.alignSelf = .end

        return layout
    }

    private func deliveryButtonLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let substrate = substrateLayout()

        changeOrderTypeButton.style.preferredSize = CGSize(width: 44, height: 44)
        orderWithDeliveryButton.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 44)

        let insets = UIEdgeInsets(top: 0, left: CGFloat.infinity, bottom: 0, right: 0)
        let substrateInsetLayout = ASInsetLayoutSpec(insets: insets, child: substrate)
        let substrateOverDeliveryButton = ASOverlayLayoutSpec(child: orderWithDeliveryButton, overlay: substrateInsetLayout)

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
        let layout = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 16, bottom: 10, right: 0),
                child: recommendationsTitleNode)
        layout.style.alignSelf = .start

        return layout
    }
}

extension CartToolbarNode: ASCollectionDataSource, ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let context = contexts[indexPath.item]
        
        return {
            let cell = DefaultCellNode(context: context)
            cell.backgroundColor = PaperColor.White.withAlphaComponent(0)

            return cell
        }
    }

    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return contexts.count
    }

    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        return recommendedCategoryCellConstrainedSize
    }
}
