import Foundation
import AsyncDisplayKit

class ProductOptionsNode: ASDisplayNode {
    
    var product: ProductEntity? {
        didSet {
            contentNode.product = product
        }
    }
    
    private var contentNode = ProductOptionsContentNode()
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true        
    }
    
    override func didLoad() {
        super.didLoad()
        
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 3
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASStackLayoutSpec.vertical()
        layout.style.preferredSize = constrainedSize.max
        
        let pusher = ASLayoutSpec()
        let pusherHeight: CGFloat = 62
        pusher.style.height = ASDimension(unit: .points, value: pusherHeight)
        
        let contentSize = CGSize(width: constrainedSize.max.width,
                                 height: constrainedSize.max.height - pusherHeight)
        let contentLayout = contentLayoutSpecThatFits(ASSizeRange(min: contentSize, max: contentSize))
        
        layout.children = [pusher, contentLayout]
        
        return layout
    }
    
    private func contentLayoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        contentNode.style.preferredSize = constrainedSize.max
        
        return ASWrapperLayoutSpec(layoutElement: contentNode)
    }
}

class ProductOptionsContentNode: ASDisplayNode {
    var product: ProductEntity? {
        didSet {
            // todo: setup nodes
        }
    }
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = PaperColor.White
    }
}
