import UIKit
import AsyncDisplayKit
import pop

protocol ProductCellNodeDelegate: class {
    func productCellNode(_ node: ProductCellNode, didSelectProduct product: Product, withPrice price: Price)
}

class ProductCellNode: ASCellNode {

    let cellInsets = Constants.ProductCellLayout.CellInsets
    let cellBackground = Constants.ProductCellLayout.BackgroundColor
    let selectedCellBackground = Constants.ProductCellLayout.SelectedBackgroundColor
    let imageCornerRadius = Constants.ProductCellLayout.ImageCornerRadius
    
    let imageNode: ASImageNode = {// todo: make it ASNetworkingNode
        let imageNode = ASImageNode()
        imageNode.contentMode = .scaleAspectFit
//        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(
//            cornerRadius: Constants.CategoryCellLayout.ImageCornerRadius)
        return imageNode
    }()

    private(set) var titleLabel = ASTextNode()
    private(set) var subtitleLabel: ASTextNode?
    private(set) var priceNodes = [PriceNode]()
    var product: Product
    weak var delegate: ProductCellNodeDelegate?
    
    init(product: Product) {
        self.product = product
        super.init()
        self.automaticallyManagesSubnodes = true
        self.selectionStyle = .none
        self.backgroundColor = cellBackground
        setupNodes()
    }

    private func setupNodes() {
        setupImageNode()
        setupTitleLabel()
        setupSubtitleLabel()
        setupPriceNodes()
    }

    private func setupImageNode() {
        //imageNode.defaultImage = UIImage(color: PaperColor.Gray300, size: Constants.CellLayout.CoatOfArmsImageSize)

        if let url = product.photoUrl {
            //    imageNode.url = URL(string: url)
            imageNode.image = UIImage(named: url)
            imageNode.addTarget(self, action: #selector(didTouchDownRepeatImage), forControlEvents: .touchDownRepeat)
        }
        // todo: setup gray color placeholder image if no image provided
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
    
    private func setupTitleLabel() {
        titleLabel.attributedText = NSAttributedString(string: product.title, attributes: Constants.ProductCellLayout.TitleStringAttributes)
    }

    private func setupSubtitleLabel() {
        if let subtitle = product.subtitle {
            let subtitleLabel = ASTextNode()
            self.subtitleLabel = subtitleLabel
            subtitleLabel.attributedText = NSAttributedString(string: subtitle, attributes: Constants.ProductCellLayout.SubtitleStringAttributes)
        }
    }

    private func setupPriceNodes() {
        product.pricing.forEach {
            let priceNode = PriceNode(price: $0)
            priceNode.delegate = self
            priceNodes.append(priceNode)
        }
    }

    override func didLoad() {
        super.didLoad()
        
        imageNode.cornerRadius = imageCornerRadius // todo: use optimized corner radius, update corner radius in ASNetworkImageNodeDelegate
        imageNode.clipsToBounds = true
    }        
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let resultStack = ASStackLayoutSpec.vertical()
        var resultStackChildren = [ASLayoutElement]()
        
        resultStackChildren.append(layoutSpecForImage())
        resultStackChildren.append(layoutSpecForTitle())
        if let subtitleLayout = layoutSpecForSubtitle() {
            resultStackChildren.append(subtitleLayout)
        }
        resultStackChildren.append(layoutSpecForPricing(constrainedSize))
        
        resultStack.children = resultStackChildren
        
        return ASInsetLayoutSpec(insets: cellInsets, child: resultStack)
    }
    
    private func layoutSpecForImage() -> ASLayoutSpec {
        var imageRatio: CGFloat = 0.5
        if let image = imageNode.image {
            imageRatio = image.size.height / image.size.width
        }
        
        return ASRatioLayoutSpec(ratio: imageRatio, child: imageNode)
    }
    
    private func layoutSpecForTitle() -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: Constants.ProductCellLayout.TitleLabelInsets, child: titleLabel)
    }
    
    private func layoutSpecForSubtitle() -> ASLayoutSpec? {
        guard let subtitleLabel = subtitleLabel else {
            return nil
        }
    
        return ASInsetLayoutSpec(insets: Constants.ProductCellLayout.SubtitleLabelInsets, child: subtitleLabel)
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
    func priceNode(_ node: PriceNode, didTouchPrice price: Price) {
        delegate?.productCellNode(self, didSelectProduct: product, withPrice: price)
    }
}
