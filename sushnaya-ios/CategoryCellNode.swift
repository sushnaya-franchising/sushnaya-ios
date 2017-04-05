import UIKit
import AsyncDisplayKit

class CategoryCellNode: ASCellNode {

    // todo: selection background

    let imageNode: ASImageNode = {// todo: make it ASNetworkingNode
        let imageNode = ASImageNode()
        imageNode.contentMode = .scaleAspectFit
        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(
            cornerRadius: Constants.CategoryCellLayout.ImageCornerRadius)
        return imageNode
    }()

    let titleLabel = ASTextNode()
    let subtitleLabel = ASTextNode()    

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? Constants.CategoryCellLayout.SelectedBackgroundColor:
                Constants.CategoryCellLayout.BackgroundColor
        }
    }
    
    init(category: MenuCategory) {
        super.init()

        automaticallyManagesSubnodes = true
        backgroundColor = Constants.CategoryCellLayout.BackgroundColor
        
        setupNodes(category)
    }

    private func setupNodes(_ category: MenuCategory) {        
        setupImageNode(category)
        setupTitleLabel(category)
        setupSubtitleLabel(category)
    }

    private func setupImageNode(_ category: MenuCategory) {
        //imageNode.defaultImage = UIImage(color: PaperColor.Gray300, size: Constants.CellLayout.CoatOfArmsImageSize)

        if let url = category.photoUrl {
            //    imageNode.url = URL(string: url)
            imageNode.image = UIImage(named: url)
        }
        // todo: setup gray color placeholder image if no image provided
    }

    private func setupTitleLabel(_ category: MenuCategory) {
        titleLabel.attributedText = NSAttributedString(string: category.title, attributes: Constants.CategoryCellLayout.TitleStringAttributes)
    }

    private func setupSubtitleLabel(_ category: MenuCategory) {
        if let subtitle = category.subtitle {
            subtitleLabel.attributedText = NSAttributedString(string: subtitle, attributes: Constants.CategoryCellLayout.SubtitleStringAttributes)            
        }
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var imageRatio: CGFloat = 0.5
        if imageNode.image != nil {
            imageRatio = (imageNode.image?.size.height)! / (imageNode.image?.size.width)!
        }

        let imageNodeSpec = ASRatioLayoutSpec(ratio: imageRatio, child: imageNode)
        let titleLabelSpec = ASInsetLayoutSpec(insets: Constants.CategoryCellLayout.TitleLabelInsets, child: titleLabel)
        let subtitleLabelSpec = ASInsetLayoutSpec(insets: Constants.CategoryCellLayout.SubtitleLabelInsets, child: subtitleLabel)
        
        let stackLayout = ASStackLayoutSpec.vertical()
        stackLayout.alignItems = .start
        stackLayout.justifyContent = .start
        stackLayout.style.flexShrink = 1.0
        stackLayout.children = [imageNodeSpec, titleLabelSpec, subtitleLabelSpec]

        return ASInsetLayoutSpec(insets: Constants.CategoryCellLayout.CellInsets, child: stackLayout)
    }
}
