import UIKit
import AsyncDisplayKit

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

    let titleLabel = ASTextNode()
    private(set) var subtitleLabel: ASTextNode?
    let priceLabel = ASTextNode()

    init(product: Product) {
        super.init()

        self.automaticallyManagesSubnodes = true
        self.selectionStyle = .none
        self.backgroundColor = cellBackground
        
        setupNodes(product)
    }

    private func setupNodes(_ product: Product) {
        setupImageNode(product)
        setupTitleLabel(product)
        setupPriceLabel(product)
        setupSubtitleLabel(product)
    }

    private func setupImageNode(_ product: Product) {
        //imageNode.defaultImage = UIImage(color: PaperColor.Gray300, size: Constants.CellLayout.CoatOfArmsImageSize)

        if let url = product.photoUrl {
            //    imageNode.url = URL(string: url)
            imageNode.image = UIImage(named: url)
        }
        // todo: setup gray color placeholder image if no image provided
    }
    
    private func setupTitleLabel(_ product: Product) {
        titleLabel.attributedText = NSAttributedString(string: product.title, attributes: Constants.ProductCellLayout.TitleStringAttributes)
    }

    private func setupPriceLabel(_ product: Product) {
        priceLabel.attributedText = NSAttributedString(string: product.formattedPrice, attributes: Constants.ProductCellLayout.PriceStringAttributes)
    }

    private func setupSubtitleLabel(_ product: Product) {
        if let subtitle = product.subtitle {
            subtitleLabel = ASTextNode()
            subtitleLabel!.attributedText = NSAttributedString(string: subtitle, attributes: Constants.ProductCellLayout.SubtitleStringAttributes)
        }
    }

    override func didLoad() {
        super.didLoad()
        
        layer.cornerRadius =  imageCornerRadius + min(cellInsets.left, cellInsets.top, cellInsets.right, cellInsets.bottom)
        
        imageNode.layer.cornerRadius = imageCornerRadius // todo: use optimized corner radius, update corner radius in ASNetworkImageNodeDelegate
        imageNode.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var imageRatio: CGFloat = 0.5
        if let image = imageNode.image {
            imageRatio = image.size.height / image.size.width
        }
        
        let imageNodeLayout = ASRatioLayoutSpec(ratio: imageRatio, child: imageNode)

        var priceStackChildren = [ASLayoutElement]()
        
        let priceStack = ASStackLayoutSpec.horizontal()
        priceStack.alignItems = .end

        let spacer = ASLayoutSpec()
        spacer.style.flexGrow = 1.0
        priceStackChildren.append(spacer)

        priceLabel.style.flexShrink = 1.0
        priceStackChildren.append(priceLabel)
        priceStack.children = priceStackChildren
        
        var resultStackChildren = [ASLayoutElement]()
        let resultStack = ASStackLayoutSpec.vertical()
        
        resultStackChildren.append(imageNodeLayout)
        resultStackChildren.append(ASInsetLayoutSpec(insets: Constants.ProductCellLayout.TitleLabelInsets, child: titleLabel))
        
        if let subtitleLabel = subtitleLabel {
            resultStackChildren.append(ASInsetLayoutSpec(insets: Constants.ProductCellLayout.SubtitleLabelInsets, child: subtitleLabel))
        }
        
        resultStackChildren.append(ASInsetLayoutSpec(insets: Constants.ProductCellLayout.PriceLabelInsets, child: priceStack))
        
        resultStack.children = resultStackChildren
        
        return ASInsetLayoutSpec(insets: cellInsets, child: resultStack)
    }
}
