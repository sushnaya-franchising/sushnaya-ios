import Foundation
import AsyncDisplayKit
import CoreStore

class SelectMenuNode: ASDisplayNode {
    
    fileprivate var headerTextNode = ASTextNode()
    fileprivate var subheadingTextNode = ASTextNode()
    var tableNode = ASTableNode()    
    
    lazy var headerStringAttributes: [String: AnyObject] = {
        return [
                NSForegroundColorAttributeName: PaperColor.Gray800,
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)
        ]
    }()

    lazy var subheadingStringAttributes: [String: AnyObject] = {
        return [
                NSForegroundColorAttributeName: PaperColor.Gray500,
                NSFontAttributeName: UIFont.systemFont(ofSize: 14)
        ]
    }()

    override init() {
        super.init()

        self.automaticallyManagesSubnodes = true
        self.backgroundColor = UIColor.white

        setupNodes()
    }
    
    private func setupNodes() {
        setupHeading()
        setupTableNode()
    }
    
    private func setupTableNode() {
        tableNode.view.separatorStyle = .none
    }        

    private func setupHeading() {
        headerTextNode.attributedText = NSAttributedString(string: "Выберите город", attributes: headerStringAttributes)
        subheadingTextNode.attributedText = NSAttributedString(string: "В каком городе вы хотите сделать заказ?", attributes: subheadingStringAttributes)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec.vertical()
        stack.justifyContent = .start
        stack.spacing = 16

        let headerLayout = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 64, left: 64, bottom: 0, right: 64), child: headerTextNode)
        let subheadingLayout = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 64), child: subheadingTextNode)
        tableNode.style.preferredSize = constrainedSize.max

        stack.children = [headerLayout, subheadingLayout, tableNode]
        
        return stack
    }
}
