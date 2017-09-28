import Foundation
import AsyncDisplayKit

protocol SelectAddressNavbarDelegate: class {
    func selectAddressNavbarDidTapBackButton(node: SelectAddressNavbarNode)
    
    func selectAddressNavbarDidTapEditButton(node: SelectAddressNavbarNode)
}

class SelectAddressNavbarNode: ASDisplayNode {
    static let DismissIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .chevronDown), attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 16), NSForegroundColorAttributeName: PaperColor.Gray800])
    static let EditIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .pencil), attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 16), NSForegroundColorAttributeName: PaperColor.Gray])
    static let EditDarkIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .pencil), attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 16), NSForegroundColorAttributeName: PaperColor.Gray800])
    
    let backButtonNode = ASButtonNode()
    let editButtonNode = ASButtonNode()
    let backgroundNode = ASDisplayNode()
    let titleTextNode = ASTextNode()
    
    var title: String? {
        didSet {
            setupTitleNode()
        }
    }
    
    weak var delegate: SelectAddressNavbarDelegate?
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        editButtonNode.setTargetClosure { [unowned self] _ in
            self.delegate?.selectAddressNavbarDidTapEditButton(node: self)
        }
        
        backButtonNode.setTargetClosure { [unowned self] _ in
            self.delegate?.selectAddressNavbarDidTapBackButton(node: self)
        }
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupBackgroundNode()
        setupBackButtonNode()
        setupTitleNode()
        setupEditButtonNode()
    }
    
    
    private func setupEditButtonNode() {
        editButtonNode.setAttributedTitle(SelectAddressNavbarNode.EditIconString, for: .normal)
        editButtonNode.setBackgroundImage(UIImage.init(color: PaperColor.Gray100), for: .selected)
        editButtonNode.setAttributedTitle(SelectAddressNavbarNode.EditDarkIconString, for: .selected)
    }
    
    private func setupTitleNode() {
        guard let title = title else {
            return
        }
        
        titleTextNode.attributedText = NSAttributedString(string: title, attributes: [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)
        ])
    }
    
    private func setupBackButtonNode() {
        backButtonNode.setAttributedTitle(SelectAddressNavbarNode.DismissIconString, for: .normal)
    }
    
    private func setupBackgroundNode() {
        backgroundNode.backgroundColor = PaperColor.White.withAlphaComponent(0.93)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subnode in subnodes {
            if subnode.hitTest(convert(point, to: subnode), with: event) != nil {
                return true
            }
        }
        return false
    }
    
    override func didLoad() {
        super.didLoad()
        editButtonNode.cornerRadius = 11
        editButtonNode.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        backButtonNode.hitTestSlop = UIEdgeInsets(top: -22, left: -22, bottom: -22, right: -22)
        backButtonNode.style.preferredSize = CGSize(width: 44, height: 44)
        let backButtonLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(24, 16, 0, 0), child: backButtonNode)
        
        let backButtonRow = ASStackLayoutSpec.horizontal()
        backButtonRow.alignItems = .start
        backButtonRow.children = [backButtonLayout]
        
        let titleLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(36, 0, 0, 0), child: titleTextNode)
        
        let titleRow = ASStackLayoutSpec.horizontal()
        titleRow.alignItems = .start
        titleRow.justifyContent = .center
        titleRow.children = [titleLayout]
        
        editButtonNode.hitTestSlop = UIEdgeInsets(top: -22, left: -22, bottom: -22, right: -22)
        editButtonNode.style.preferredSize = CGSize(width: 44, height: 44)
        let editIconLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(24, 0, 0, 16), child: editButtonNode)
        
        let editIconRow = ASStackLayoutSpec.horizontal()
        editIconRow.alignItems = .start
        editIconRow.justifyContent = .end
        editIconRow.children = [editIconLayout]
        
        let backgroundRow = ASStackLayoutSpec.horizontal()
        backgroundNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 72)
        backgroundRow.children = [backgroundNode]
        
        return ASOverlayLayoutSpec(child: ASOverlayLayoutSpec(child: ASOverlayLayoutSpec(child: backgroundRow, overlay: titleRow), overlay: backButtonRow), overlay: editIconRow)
    }
}
