import Foundation
import AsyncDisplayKit

class DefaultCellNode: ASCellNode {
    let imageNode: ASNetworkImageNode = {
        let imageNode = ASNetworkImageNode()
        imageNode.contentMode = .scaleAspectFit
        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(cornerRadius: 20)
        return imageNode
    }()

    let titleLabel = ASTextNode()
    
    var context: DefaultCellContext {
        didSet {
            setupNodes()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = PaperColor.White
        }
    }
    
    init(context: DefaultCellContext) {
        self.context = context
        
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.selectionStyle = .none
        self.backgroundColor = context.style.backgroundColor
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupImageNode()
        setupTitleLabel()
    }
    
    private func setupImageNode() {
        imageNode.placeholderEnabled = true
        imageNode.placeholderColor = PaperColor.Gray100
        imageNode.placeholderFadeDuration = 0.1
        
        if let url = context.imageUrl {
            imageNode.url = URL(string: url)
        }
    }

    private func setupTitleLabel() {
        titleLabel.attributedText = NSAttributedString(string: context.title, attributes: context.style.titleStringAttributes)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {        
        let stack = ASStackLayoutSpec.vertical()
        var children = [ASLayoutElement]()
        stack.alignItems = .center
        stack.justifyContent = .start
        
        if let imageSize = context.preferredImageSize {
            imageNode.style.preferredSize = imageSize
            
            children.append(imageNode)
        }
        
        titleLabel.style.maxWidth = ASDimension(unit: .points, value: context.style.imageSize.width)
        let titleLayout = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0), child: titleLabel)
        children.append(titleLayout)
        
        stack.children = children
        
        return ASInsetLayoutSpec(insets: context.style.insets, child: stack)
    }
}

class DefaultCellContext {
    var title: String
    var imageSize: CGSize?
    var imageUrl: String?
    var image: UIImage?
    var style = DefaultCellStyle()
    var preferredImageSize: CGSize?
    
    init(title: String) {
        self.title = title        
    }
    
    convenience init(title: String, style: DefaultCellStyle) {
        self.init(title: title)
        self.style = style
    }
}

struct DefaultCellStyle {
    var imageSize = Constants.DefaultCellLayout.ImageSize
    var imageCornerRadius = Constants.DefaultCellLayout.ImageCornerRadius
    var backgroundColor = Constants.DefaultCellLayout.BackgroundColor
    var selectedBackground = Constants.DefaultCellLayout.SelectedBackgroundColor
    var insets = Constants.DefaultCellLayout.CellInsets
    var titleStringAttributes = Constants.DefaultCellLayout.TitleStringAttributes
}


