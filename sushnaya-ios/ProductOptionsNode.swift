import Foundation
import AsyncDisplayKit

protocol ProductOptionsDelegate: class {
    func productOptionsDidUpdateCount(count: Int)
    func productOptionsDidSubmit()
}

protocol ProductOptionCellNodeDelegate: class {
    func productOptionsNodeDidCheck(node: ProductOptionCellNode, option: ProductOptionEntity)
    func productOptionsNodeDidUncheck(node: ProductOptionCellNode, option: ProductOptionEntity)
}

class ProductOptionsNode: ASDisplayNode {
    
    var context: ProductOptionsContext? {
        didSet {
            contentNode.context = context
        }
    }
    
    var tableNode: ASTableNode {
        return contentNode.tableNode
    }
    
    weak var delegate: ProductOptionsDelegate? {
        didSet {
            contentNode.delegate = delegate
        }
    }
    
     var contentNode = ProductOptionsContentNode()
    
    var toolbarNode: ProductOptionsToolbarNode {
        return contentNode.toolbarNode
    }
    
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
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subnode in subnodes {
            if subnode.hitTest(convert(point, to: subnode), with: event) != nil {
                return true
            }
        }
        return false
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
    
    var context: ProductOptionsContext? {
        didSet {
            headerNode.context = context
            toolbarNode.context = context
            
            setNeedsLayout()
        }
    }
    
    weak var delegate: ProductOptionsDelegate? {
        didSet {
            headerNode.delegate = delegate
            toolbarNode.delegate = delegate
        }
    }
    
    fileprivate let headerNode = ProductOptionsHeaderNode()
    fileprivate let tableNode = ASTableNode()
    fileprivate let toolbarNode = ProductOptionsToolbarNode()
    
    var toolbarOffsetBottom: CGFloat = 0
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = PaperColor.White
        
        self.tableNode.allowsSelection = false
    }
    
    override func layout() {
        super.layout()
        
        let topInset = headerNode.calculatedSize.height
        let bottomInset = toolbarNode.calculatedSize.height
        
        tableNode.view.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
        toolbarNode.frame = toolbarNode.frame.offsetBy(dx: 0, dy: -toolbarOffsetBottom)
    }
    
    override func didLoad() {
        super.didLoad()
        tableNode.view.separatorStyle = .none
        tableNode.view.showsHorizontalScrollIndicator = false
        tableNode.view.showsVerticalScrollIndicator = false
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let maxWidth = constrainedSize.max.width
        let maxHeight = constrainedSize.max.height
        
        tableNode.style.preferredSize = CGSize(width: maxWidth, height: maxHeight)
        
        let headerInsets = UIEdgeInsets(top: 0, left: 0, bottom: CGFloat.infinity, right: 0)
        let headerLayout = ASInsetLayoutSpec(insets: headerInsets, child: headerNode)
        
        let toolbarInsets = UIEdgeInsets(top: CGFloat.infinity, left: 0, bottom: 0, right: 0)
        let toolbarLayout = ASInsetLayoutSpec(insets: toolbarInsets, child: toolbarNode)
        
        let layout = ASOverlayLayoutSpec(child: tableNode, overlay: headerLayout)
        
        return ASOverlayLayoutSpec(child: layout, overlay: toolbarLayout)
    }
}

class ProductOptionsHeaderNode: ASDisplayNode {
    var context: ProductOptionsContext? {
        didSet {
            controlsNode.context = context
            setupNodes()
            setNeedsLayout()
        }
    }
    
    let imageNode: ASNetworkImageNode = {
        let imageNode = ASNetworkImageNode()
        imageNode.contentMode = .scaleAspectFill
        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(cornerRadius: 5)
        return imageNode
    }()
    
    let nameTextNode = ASTextNode()
    let controlsNode = ProductOptionsHeaderControlsNode()
    
    weak var delegate: ProductOptionsDelegate? {
        didSet {
            controlsNode.delegate = delegate
        }
    }
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = PaperColor.White.withAlphaComponent(0.93)
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupImageNode()
        setupNameTextNode()
    }
    
    private func setupImageNode() {
        imageNode.placeholderEnabled = true
        imageNode.placeholderColor = PaperColor.Gray100
        imageNode.placeholderFadeDuration = 0.1
        
        guard let url = context?.product.imageUrl else { return }
        
        imageNode.url = URL(string: url)
    }
    
    private func setupNameTextNode() {
        guard let productName = context?.product.name else { return }
        
        nameTextNode.attributedText = NSAttributedString(string: productName, attributes: [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
        ])
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        imageNode.style.preferredSize = CGSize(width: 44, height: 44)
        nameTextNode.textContainerInset = UIEdgeInsetsMake(0, 4, 0, 4)
        nameTextNode.style.maxHeight = ASDimension(unit: .points, value: 64)
        nameTextNode.style.flexShrink = 1
        
        let layout = ASStackLayoutSpec.horizontal()
        layout.alignItems = .center
        layout.children = [imageNode, nameTextNode, controlsNode]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(8, 8, 8, 8), child: layout)
    }
}

class ProductOptionsHeaderControlsNode: ASDisplayNode {
    static let MinusIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .minus),
                                                    attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 16),
                                                                 NSForegroundColorAttributeName: PaperColor.Gray])
    
    var context: ProductOptionsContext? {
        didSet {
            addControlNode.context = context
        }
    }
    
    let removeButtonNode = ASButtonNode()
    let addControlNode = ProductOptionsAddControlNode()
    
    weak var delegate: ProductOptionsDelegate?
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = PaperColor.White
        
        addControlNode.setTargetClosure { [unowned self] _ in
            self.delegate?.productOptionsDidUpdateCount(count: self.addControlNode.count + 1)
        }
        
        removeButtonNode.setAttributedTitle(ProductOptionsHeaderControlsNode.MinusIconString, for: .normal)
        removeButtonNode.setTargetClosure { [unowned self] _ in
            self.delegate?.productOptionsDidUpdateCount(count: self.addControlNode.count - 1)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        removeButtonNode.style.preferredSize = CGSize(width: 44, height: 44)
        
        let layout = ASStackLayoutSpec.horizontal()
        layout.verticalAlignment = .center
        layout.children = [removeButtonNode, addControlNode]
        
        return layout
    }
}

class ProductOptionsAddControlNode: ASControlNode {
    let countTextNode = ASTextNode()
    let addTextNode = ASTextNode()
    
    var context: ProductOptionsContext? {
        didSet {
            guard let context = context else { return }
            
            count = context.count
        }
    }
    
    var count = 1 {
        didSet {
            setupCountTextNode()
            setNeedsLayout()
        }
    }
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = PaperColor.Gray100
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupCountTextNode()
        setupAddTextNode()
    }
    
    private func setupCountTextNode() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        countTextNode.attributedText = NSAttributedString(
            string: "\(count)",
            attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 16),
                         NSForegroundColorAttributeName: PaperColor.Gray,
                         NSParagraphStyleAttributeName : paragraphStyle])
    }
    
    private func setupAddTextNode() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        addTextNode.attributedText = NSAttributedString(
            string: String.fontAwesomeIcon(name: .plus),
            attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 16),
                         NSForegroundColorAttributeName: PaperColor.Gray,
                         NSParagraphStyleAttributeName : paragraphStyle])
    }
    
    override func didLoad() {
        super.didLoad()
        
        cornerRadius = 22
        clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        countTextNode.style.minWidth = ASDimension(unit: .points, value: 44)
        countTextNode.textContainerInset = UIEdgeInsetsMake(0, 8, 0, 0)
        addTextNode.style.minWidth = ASDimension(unit: .points, value: 44)
        
        let layout = ASStackLayoutSpec.horizontal()
        layout.style.height = ASDimension(unit: .points, value: 44)
        layout.style.minWidth = ASDimension(unit: .points, value: 44)
        layout.verticalAlignment = .center
        layout.children = [countTextNode, addTextNode]
        
        return layout
    }
}

class ProductOptionsToolbarNode: ASDisplayNode {

    var context: ProductOptionsContext? {
        didSet {
            setupNodes()
            setNeedsLayout()
        }
    }

    weak var delegate: ProductOptionsDelegate?

    let sumTitleTextNode = ASTextNode()
    let sumValueTextNode = ASTextNode()
    let commentFormFieldNode = FormFieldNode(label: "Комментарий повару")
    let addToCartButton = ASButtonNode()
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = PaperColor.White.withAlphaComponent(0.93)
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupSumTitleTextNode()
        setupSumValueTextNode()
        setupCommentFormFieldNode()
        setupAddToCartButtonNode()
    }
    
    private func setupSumTitleTextNode() {
        sumTitleTextNode.attributedText = NSAttributedString(string: "Сумма с добавками", attributes: [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
            ])
    }
    
    private func setupSumValueTextNode() {
        let formattedSumPrice = context?.formattedSumPrice ?? ""
        
        sumValueTextNode.attributedText = NSAttributedString(string: formattedSumPrice, attributes: [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
            ])
    }
    
    private func setupCommentFormFieldNode() {
        commentFormFieldNode.setValue(context?.comment)
        commentFormFieldNode.returnKeyType = .done
        commentFormFieldNode.onReturn = { [unowned self] in
            self.commentFormFieldNode.resignFirstResponder()
        }
    }
    
    private func setupAddToCartButtonNode() {
        let title = NSAttributedString(string: "Добавить в корзину", attributes: [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
            ])
        addToCartButton.setAttributedTitle(title, for: .normal)
        addToCartButton.backgroundColor = PaperColor.Gray200
        addToCartButton.setTargetClosure { [unowned self] _ in
            self.view.endEditing(true)
            
            self.delegate?.productOptionsDidSubmit()
        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        addToCartButton.cornerRadius = 11
        addToCartButton.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let sumStackLayout = ASStackLayoutSpec.horizontal()
        sumStackLayout.spacing = 32
        sumStackLayout.alignItems = .center
        sumStackLayout.children = [sumTitleTextNode, sumValueTextNode]
        let sumLayout = ASCenterLayoutSpec(centeringOptions: .X, sizingOptions: [], child:
            ASInsetLayoutSpec(insets: UIEdgeInsetsMake(16, 0, 0, 0), child: sumStackLayout))
        
        let commentFieldLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(16, 16, 16, 16), child: commentFormFieldNode)
        
        self.addToCartButton.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 44)
        let addToCartButtonLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(16, 16, 16, 16), child: addToCartButton)
        
        let layout = ASStackLayoutSpec.vertical()
        layout.children = [sumLayout, commentFieldLayout, addToCartButtonLayout]
        
        return layout
    }
}

class ProductOptionCellNode: ASCellNode {
    fileprivate var productOption: ProductOptionEntity
    fileprivate let nameTextNode = ASTextNode()
    fileprivate var modifierTextNode: ASTextNode?
    fileprivate let priceTextNode = ASTextNode()
    fileprivate var addButtonNode = ASButtonNode()
    
    var isChecked = false {
        didSet {
            guard isChecked != oldValue else { return }
            
            if isChecked {
                delegate?.productOptionsNodeDidCheck(node: self, option: productOption)
            
            } else {
                delegate?.productOptionsNodeDidUncheck(node: self, option: productOption)
            }
            
            setupAddButtonNode()
        }
    }
    
    weak var delegate: ProductOptionCellNodeDelegate?
    
    init(productOption: ProductOptionEntity) {
        self.productOption = productOption
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        addButtonNode.setTargetClosure { [unowned self] _ in
            self.isChecked = !self.isChecked
        }
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupNameTextNode()
        setupModifierTextNode()
        setupPriceTextNode()
        setupAddButtonNode()
    }
    
    private func setupNameTextNode() {
        nameTextNode.attributedText =  NSAttributedString(
            string: productOption.name,
            attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 14),
                         NSForegroundColorAttributeName: PaperColor.Gray800])
    }
    
    private func setupModifierTextNode() {
        guard let modifierName = productOption.price.modifierName else { return }
        
        modifierTextNode = ASTextNode()
        modifierTextNode?.attributedText =  NSAttributedString(
            string: modifierName,
            attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 10),
                         NSForegroundColorAttributeName: PaperColor.Gray])
    }
    
    private func setupPriceTextNode() {
        priceTextNode.attributedText = NSAttributedString(
            string: productOption.price.formattedValue,
            attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 14),
                         NSForegroundColorAttributeName: PaperColor.Gray800])
    }
    
    private func setupAddButtonNode() {
        addButtonNode.setAttributedTitle(NSAttributedString(
            string: isChecked ? String.fontAwesomeIcon(name: .check) : String.fontAwesomeIcon(name: .plusCircle),
            attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 16),
                         NSForegroundColorAttributeName: isChecked ? PaperColor.Gray800: PaperColor.Gray]), for: .normal)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacer = ASLayoutSpec()
        spacer.style.flexGrow = 1
        
        addButtonNode.style.preferredSize = CGSize(width: 44, height: 44)
        
        nameTextNode.style.flexShrink = 1
        
        let layout = ASStackLayoutSpec.horizontal()
        layout.spacing = 8
        layout.alignItems = .center
        
        var children = [ASLayoutElement]()
        children.append(nameTextNode)
        children.append(spacer)
        
        if let modifierTextNode = modifierTextNode {
            children.append(modifierTextNode)
        }
        
        children.append(priceTextNode)
        children.append(addButtonNode)
        
        layout.children = children
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8), child: layout)
    }
}
