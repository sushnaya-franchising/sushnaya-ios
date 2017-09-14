import Foundation
import AsyncDisplayKit
import UIKit

class MenuCellNode: ASCellNode {

    fileprivate var titleLabel = ASTextNode()

    fileprivate var imageNode: ASNetworkImageNode = {
        let imageNode = ASNetworkImageNode()
        imageNode.contentMode = .scaleAspectFit
        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(cornerRadius: 10)
        return imageNode
    }()

    lazy var titleStringAttributes: [String: AnyObject] = {
        return [
                NSFontAttributeName: UIFont.systemFont(ofSize: 17)
        ]
    }()

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? PaperColor.Gray100: PaperColor.White
        }
    }

    var menu: MenuEntity {
        didSet {
            setupNodes()
        }
    }
    
    init(menu: MenuEntity) {
        self.menu = menu
        
        super.init()

        self.selectionStyle = .none
        self.automaticallyManagesSubnodes = true

        setupNodes()
    }

    private func setupNodes() {
        setupTitleLabel()
        setupImageNode()
    }

    private func setupTitleLabel() {
        titleLabel.attributedText = NSAttributedString(string: menu.locality.name, attributes: titleStringAttributes)
    }

    private func setupImageNode() {
        imageNode.placeholderEnabled = true
        imageNode.placeholderColor = PaperColor.Gray100
        imageNode.placeholderFadeDuration = 0.1
        
        let coordinate = CLLocationCoordinate2D(latitude: menu.locality.latitude,
                                                longitude: menu.locality.longitude)
        
        imageNode.url = FoodServiceImages.getCoatOfArmsImageUrl(coordinate: coordinate)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec.horizontal()
        stack.justifyContent = .start
        stack.alignItems = .center

        imageNode.style.preferredSize = Constants.LocalityCellLayout.CoatOfArmsImageSize
        let imageNodeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        let imageNodeLayoutSpec = ASInsetLayoutSpec(insets: imageNodeInsets, child: imageNode)

        stack.children = [imageNodeLayoutSpec, titleLabel]

        let rowInsets = UIEdgeInsets(top: 16, left: 64, bottom: 16, right: 64)
        return ASInsetLayoutSpec(insets: rowInsets, child: stack)
    }
}
