import UIKit
import AsyncDisplayKit
import pop

protocol ProductCellNodeDelegate: class {
    func productCellNode(_ node: ProductCellNode, didSelectProduct product: ProductEntity, withPrice price: PriceEntity)
}

class ProductCellNode: ASCellNode {

    let cellInsets = Constants.ProductCellLayout.CellInsets
    let cellBackground = Constants.ProductCellLayout.BackgroundColor
    let selectedCellBackground = Constants.ProductCellLayout.SelectedBackgroundColor
    let imageCornerRadius = Constants.ProductCellLayout.ImageCornerRadius
    
    let imageNode: ASNetworkImageNode = {
        let imageNode = ASNetworkImageNode()
        imageNode.contentMode = .scaleAspectFit
        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(cornerRadius: 15)
        return imageNode
    }()
    
    private(set) var titleTextNode = ASTextNode()
    private(set) var subtitleTextNode: ASTextNode?
    private(set) var priceNodes = [PriceNode]()
    
    weak var delegate: ProductCellNodeDelegate?
    
    var product: ProductEntity {
        didSet {
            setupNodes()
        }
    }
    
    init(product: ProductEntity) {
        self.product = product
        super.init()
        self.automaticallyManagesSubnodes = true
        self.selectionStyle = .none
        self.backgroundColor = cellBackground
        setupNodes()
    }

    private func setupNodes() {
        setupImageNode()
        setupTitleTextNode()
        setupSubtitleTextNode()
        setupPriceNodes()
    }

    private func setupImageNode() {
        imageNode.placeholderEnabled = true
        imageNode.placeholderColor = PaperColor.Gray100
        imageNode.placeholderFadeDuration = 0.1

        if let url = product.imageUrl {
            imageNode.url = URL(string: url)
            imageNode.addTarget(self, action: #selector(didTouchDownRepeatImage), forControlEvents: .touchDownRepeat)
        }        
    }
    
    func didTouchDownRepeatImage() {
        if let price = product.highestPrice {
            delegate?.productCellNode(self, didSelectProduct: product, withPrice: price)
            
            animateFlash()
        }
    }
    
    private func animateFlash() {        
        let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        alphaAnimation?.fromValue = 0.1
        alphaAnimation?.toValue = 1
        alphaAnimation?.duration = 1
        
        imageNode.pop_removeAllAnimations()
        imageNode.pop_add(alphaAnimation, forKey: "alpha")
    }
    
    private func setupTitleTextNode() {
        titleTextNode.attributedText = NSAttributedString(string: product.name, attributes: Constants.ProductCellLayout.TitleStringAttributes)
    }

    private func setupSubtitleTextNode() {
        if let subtitle = product.subheading {
            let subtitleTextNode = ASTextNode()
            self.subtitleTextNode = subtitleTextNode
            subtitleTextNode.attributedText = NSAttributedString(string: subtitle, attributes: Constants.ProductCellLayout.SubtitleStringAttributes)
        }
    }

    private func setupPriceNodes() {
        for price in product.pricing {
            let priceNode = PriceNode(price: price)
            priceNode.delegate = self
            priceNodes.append(priceNode)
        }
    }

    override func didLoad() {
        super.didLoad()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stackLayout = ASStackLayoutSpec.vertical()
        var stackChildren = [ASLayoutElement]()
        
        if let imageSize = product.imageSize {
            let imageRatio = imageSize.height / imageSize.width
            let imageLayout = ASRatioLayoutSpec(ratio: imageRatio, child: imageNode)
            
            stackChildren.append(imageLayout)
        }
        
        titleTextNode.style.maxWidth = ASDimension(unit: .points, value: constrainedSize.max.width)
        stackChildren.append(titleTextNode)
        
        if let subtitleTextNode = subtitleTextNode {
            subtitleTextNode.style.maxWidth = ASDimension(unit: .points, value: constrainedSize.max.width)
            stackChildren.append(subtitleTextNode)
        }
        
        stackChildren.append(layoutSpecForPricing(constrainedSize))        
        
        stackLayout.children = stackChildren
        
        return  ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: stackLayout)
        
        
//        let resultStack = ASStackLayoutSpec.vertical()
//        var resultStackChildren = [ASLayoutElement]()
//        
//        if let imageLayout = layoutSpecForImage(constrainedWidth: constrainedSize.max.width) {
//            resultStackChildren.append(imageLayout)
//        }
//        
//        resultStackChildren.append(layoutSpecForTitle())
//        
//        if let subtitleLayout = layoutSpecForSubtitle() {
//            resultStackChildren.append(subtitleLayout)
//        }
//        
//        resultStackChildren.append(layoutSpecForPricing(constrainedSize))
//        
//        resultStack.children = resultStackChildren
//        
//        return ASInsetLayoutSpec(insets: cellInsets, child: resultStack)
    }
    
    private func layoutSpecForImage(constrainedWidth: CGFloat) -> ASLayoutSpec? {
        guard let imageSize = product.imageSize else {
            return nil
        }
        
        imageNode.style.preferredSize = CGSize(width: constrainedWidth,
                                               height: imageSize.height / (imageSize.width / constrainedWidth))
        
        return ASWrapperLayoutSpec(layoutElement: imageNode)
    }
    
    private func layoutSpecForTitle() -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: Constants.ProductCellLayout.TitleLabelInsets, child: titleTextNode)
    }
    
    private func layoutSpecForSubtitle() -> ASLayoutSpec? {
        guard let subtitleTextNode = subtitleTextNode else {
            return nil
        }
    
        return ASInsetLayoutSpec(insets: Constants.ProductCellLayout.SubtitleLabelInsets, child: subtitleTextNode)
    }
    
    private func layoutSpecForPricing(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASStackLayoutSpec.vertical()
        layout.spacing = Constants.ProductCellLayout.PricingRowSpacing

        priceNodes.forEach{
            $0.style.flexGrow = 1.0
            layout.children?.append($0)
        }
        
        return ASInsetLayoutSpec(insets: Constants.ProductCellLayout.PricingInsets, child: layout)
    }
}

extension ProductCellNode: PriceNodeDelegate {
    func priceNode(_ node: PriceNode, didTouchPrice price: PriceEntity) {
        delegate?.productCellNode(self, didSelectProduct: product, withPrice: price)
    }
}
