import Foundation
import AsyncDisplayKit
import UIKit

class MenuCellNode: ASCellNode {

    var titleLabel = ASTextNode()

    var imageNode: ASNetworkImageNode = {
        let imageNode = ASNetworkImageNode()
//        imageNode.contentMode = .scaleAspectFit
//        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(cornerRadius: 10)
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

    init(menuDto: MenuDto) {
        super.init()

        self.selectionStyle = .none
        self.automaticallyManagesSubnodes = true

        setupNodes(menuDto)
    }

    private func setupNodes(_ menuDto: MenuDto) {
        setupTitleLabel(menuDto)
        setupImageNode(menuDto)
    }

    private func setupTitleLabel(_ menuDto: MenuDto) {
        titleLabel.attributedText = NSAttributedString(string: menuDto.locality.name, attributes: titleStringAttributes)
    }

    private func setupImageNode(_ menuDto: MenuDto) {
        imageNode.defaultImage = UIImage(color: PaperColor.Gray300, size: Constants.LocalityCellLayout.CoatOfArmsImageSize)
        
        let coordinate = CLLocationCoordinate2D(latitude: menuDto.locality.latitude,
                                                longitude: menuDto.locality.longitude)
        
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
