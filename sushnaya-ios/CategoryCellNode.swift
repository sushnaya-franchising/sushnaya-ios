import UIKit
import AsyncDisplayKit

class CategoryCellNode: ASCellNode {

    let cellInsets = Constants.CategoryCellLayout.CellInsets
    let cellBackground = Constants.CategoryCellLayout.BackgroundColor
    let selectedCellBackground = Constants.CategoryCellLayout.SelectedBackgroundColor
    let imageCornerRadius = Constants.CategoryCellLayout.ImageCornerRadius
    
    let imageNode: ASImageNode = {// todo: make it ASNetworkingNode
        let imageNode = ASImageNode()
        imageNode.contentMode = .scaleAspectFit
//        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(
//            cornerRadius: Constants.CategoryCellLayout.ImageCornerRadius)
        return imageNode
    }()

    let titleLabel = ASTextNode()
    let subtitleLabel = ASTextNode()    

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? selectedCellBackground: cellBackground
        }
    }
    
    init(category: MenuCategory) {
        super.init()

        self.automaticallyManagesSubnodes = true
        self.selectionStyle = .none
        self.backgroundColor = cellBackground
        
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
        let titleLabelLayout = ASInsetLayoutSpec(insets: Constants.CategoryCellLayout.TitleLabelInsets, child: titleLabel)
        let subtitleLabelLayout = ASInsetLayoutSpec(insets: Constants.CategoryCellLayout.SubtitleLabelInsets, child: subtitleLabel)
        
        let stackLayout = ASStackLayoutSpec.vertical()
        stackLayout.alignItems = .start
        stackLayout.justifyContent = .start
        stackLayout.style.flexShrink = 1.0
        stackLayout.children = [imageNodeLayout, titleLabelLayout, subtitleLabelLayout]

        return ASInsetLayoutSpec(insets: cellInsets, child: stackLayout)
    }
}
