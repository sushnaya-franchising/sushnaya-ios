import UIKit
import AsyncDisplayKit

protocol ProductCellNodeDelegate {
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
    var delegate: ProductCellNodeDelegate?
    
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
        }
        // todo: setup gray color placeholder image if no image provided
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
    
    // todo: wait for the asyncdisplaykit flex wrap support and then remove this hack
    private func layoutSpecForPricing(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        func createRow() -> ASStackLayoutSpec {
            let row = ASStackLayoutSpec.horizontal()
            row.spacing = Constants.ProductCellLayout.PricingNodeSpacing
            return row
        }
        
        let column = ASStackLayoutSpec.vertical()
        column.spacing = Constants.ProductCellLayout.PricingRowSpacing
        
        var row = createRow()
        row.justifyContent = priceNodes.count < 3 ? .end: .start
        
        let maxWidth = constrainedSize.max.width - (
            Constants.ProductCellLayout.PricingInsets.left +
            Constants.ProductCellLayout.PricingInsets.right +
            Constants.ProductCellLayout.CellInsets.left +
            Constants.ProductCellLayout.CellInsets.right
        )
        var width:CGFloat = 0
        
        for node in priceNodes {            
            let size = node.calculateSizeThatFits(constrainedSize.max)
            width = width + size.width + (width == 0 ? 0: Constants.ProductCellLayout.PricingNodeSpacing)
            
            if width > maxWidth {
                column.children?.append(row)
                width = 0
                row = createRow()
            }
            
            row.children?.append(node)
        }
        
        column.children?.append(row)
        
        return ASInsetLayoutSpec(insets: Constants.ProductCellLayout.PricingInsets, child: column)
    }
}

extension ProductCellNode: PriceNodeDelegate {
    func priceNode(_ node: PriceNode, didTouchPrice price: Price) {
        delegate?.productCellNode(self, didSelectProduct: product, withPrice: price)
    }
}
