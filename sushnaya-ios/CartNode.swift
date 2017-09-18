import Foundation
import AsyncDisplayKit
import FontAwesome_swift

protocol CartNodeDelegate: class {
    func cartNodeDidTouchUpInsideCloseButton()

    func cartNodeDidTouchUpInsideOrderWithDeliveryButton()
}

class CartNode: ASDisplayNode {
    
    let iconNode = ASImageNode()
    let cartContentNode: CartContentNode
    weak var delegate: CartNodeDelegate?

    init(cart: Cart) {
        cartContentNode = CartContentNode(cart: cart)
        super.init()

        automaticallyManagesSubnodes = true

        iconNode.image = UIImage.fontAwesomeIcon(name: .shoppingBasket, textColor: PaperColor.White, size: CGSize(width: 130, height: 130))
        iconNode.contentMode = .bottom
        iconNode.setTargetClosure { [unowned self] _ in
            self.delegate?.cartNodeDidTouchUpInsideCloseButton()
        }
        
        cartContentNode.toolBarNode.orderWithDeliveryButton.addTarget(self, action: #selector(didTouchUpInsideOrderWithDeliveryButton), forControlEvents: .touchUpInside)
    }

    func didTouchUpInsideOrderWithDeliveryButton() {
        delegate?.cartNodeDidTouchUpInsideOrderWithDeliveryButton()
    }

    override func didLoad() {
        super.didLoad()
        
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 3
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let backLayout = backLayoutSpecThatFits(constrainedSize)
        let frontLayout = frontLayoutSpecThatFits(constrainedSize)

        return ASOverlayLayoutSpec(child: backLayout, overlay: frontLayout)
    }

    private func backLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASStackLayoutSpec.vertical()
        layout.alignItems = .center

        let backPusher = ASLayoutSpec()
        backPusher.style.height = ASDimension(unit: .points, value: 8)

        let imageSize = iconNode.image!.size
        iconNode.style.preferredSize = CGSize(width: constrainedSize.max.width,
                                              height: imageSize.height)

        layout.children = [backPusher, iconNode]

        return layout
    }

    private func frontLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let frontLayout = ASStackLayoutSpec.vertical()
        frontLayout.style.preferredSize = constrainedSize.max

        let frontPusher = ASLayoutSpec()
        let frontPusherHeight: CGFloat = 62
        frontPusher.style.height = ASDimension(unit: .points, value: frontPusherHeight)

        let contentSize = CGSize(width: constrainedSize.max.width,
                height: constrainedSize.max.height - frontPusherHeight)
        let contentLayout = contentLayoutSpecThatFits(ASSizeRange(min: contentSize, max: contentSize))

        frontLayout.children = [frontPusher, contentLayout]

        return frontLayout
    }

    private func contentLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        cartContentNode.style.preferredSize = constrainedSize.max

        return ASWrapperLayoutSpec(layoutElement: cartContentNode)
    }
}
