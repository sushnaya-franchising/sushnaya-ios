import Foundation
import AsyncDisplayKit
import pop

protocol PriceNodeDelegate: class {
    func priceNode(_ node: PriceNode, didTouchPrice price: PriceEntity)
}

class PriceNode: ASDisplayNode {
    private(set) var modifierLabel: ASTextNode?
    private(set) var priceButton = ASButtonNode()
    let checkIconNode = ASImageNode()
    
    weak var delegate: PriceNodeDelegate?
    let price: PriceEntity
    
    init(price: PriceEntity) {
        self.price = price
        super.init()
        
        automaticallyManagesSubnodes = true
        setupSubnodes()
        buildSubnodeHierarchy()        
    }
    
    private func buildSubnodeHierarchy() {
        if let modifierLabel = modifierLabel {
            addSubnode(modifierLabel)
        }
        addSubnode(priceButton)
    }
    
    private func setupSubnodes() {
        setupModifierLabel()
        setupPriceButton()
        setupCheckIcon()
    }
    
    private func setupModifierLabel() {
        guard let modifierName = price.modifierName else { return }
        
        let modifierLabel = ASTextNode()
        modifierLabel.attributedText = NSAttributedString(string: modifierName, attributes:
            Constants.ProductCellLayout.PriceModifierStringAttributes)
        self.modifierLabel = modifierLabel
    }
    
    private func setupPriceButton() {
        let title = NSAttributedString(string: price.formattedValue, attributes: price.modifierName == nil ?
            Constants.ProductCellLayout.PriceStringAttributes : Constants.ProductCellLayout.PriceWithModifierStringAttributes)
        priceButton.setAttributedTitle(title, for: .normal)
        priceButton.backgroundColor = Constants.ProductCellLayout.PriceButtonBackgroundColor
    }
    
    private func setupCheckIcon() {
        checkIconNode.image = UIImage.fontAwesomeIcon(name: .check, textColor: Constants.ProductCellLayout.CheckIconColor,
                                                      size: Constants.ProductCellLayout.CheckIconSize)
    }
    
    override func didLoad() {
        super.didLoad()
        
        priceButton.cornerRadius = 5
        priceButton.clipsToBounds = true
        priceButton.addTarget(self, action: #selector(scalePriceToBig), forControlEvents: [.touchDown, .touchDragInside])
        priceButton.addTarget(self, action: #selector(didTouchUpInsidePriceButton), forControlEvents: .touchUpInside)
        priceButton.addTarget(self, action: #selector(scalePriceToDefault), forControlEvents: [.touchDragOutside, .touchCancel])
    }
    
    func didTouchUpInsidePriceButton() {
        delegate?.priceNode(self, didTouchPrice: price)
        
        animateExplosion()
    }
    
    func scalePriceToBig() {
        let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        scaleAnimation?.toValue = NSValue.init(cgSize: CGSize(width: 1.2, height: 1.2))
        scaleAnimation?.duration = 0.3
        priceButton.pop_add(scaleAnimation, forKey: "scaleToSmall")
    }
    
    func scalePriceToDefault() {
        let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPViewScaleXY)
        scaleAnimation?.toValue = NSValue.init(cgSize: CGSize(width: 1, height: 1))
        priceButton.pop_add(scaleAnimation, forKey: "scaleToDefault")
    }
    
    private func animateExplosion() {
        let scaleAnimation = POPDecayAnimation(propertyNamed: kPOPViewScaleXY)
        scaleAnimation?.velocity = NSValue.init(cgPoint: CGPoint(x: 25, y: 25))
        
        let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        alphaAnimation?.toValue = 0
        alphaAnimation?.duration = 0.07
        alphaAnimation?.completionBlock = { [unowned self] _ in
            debounce(delay: 0.5) {
                self.animateBirth()
            }.apply()
        }
                
        self.priceButton.pop_removeAllAnimations()
        priceButton.pop_add(scaleAnimation, forKey: "scaleOut")
        priceButton.pop_add(alphaAnimation, forKey: "fadeOut")
    }
    
    private func animateBirth() {
        let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        scaleAnimation?.fromValue = NSValue.init(cgSize: CGSize(width: 0.5, height: 0.5))
        scaleAnimation?.toValue = NSValue.init(cgSize: CGSize(width: 1, height: 1))
        scaleAnimation?.springBounciness = 6
        scaleAnimation?.springSpeed = 6
        
        let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        alphaAnimation?.toValue = 1
        alphaAnimation?.duration = 0.1
        
        self.priceButton.pop_removeAllAnimations()
        priceButton.pop_add(alphaAnimation, forKey: "fadeIn")
        priceButton.pop_add(scaleAnimation, forKey: "scaleIn")
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASStackLayoutSpec.horizontal()
        layout.alignItems = .center
        
        if let modifierLabel = modifierLabel {
            modifierLabel.textContainerInset = Constants.ProductCellLayout.ModifierTextInsets
            modifierLabel.style.flexShrink = 1.0
            layout.children?.append(modifierLabel)
        }
        
        let spacer = ASLayoutSpec()
        spacer.style.flexGrow = 1.0
        layout.children?.append(spacer)
        
        priceButton.contentEdgeInsets = Constants.ProductCellLayout.PriceButtonContentInsets
        priceButton.hitTestSlop = UIEdgeInsets(top: -Constants.ProductCellLayout.PriceButtonHitTestSlopPadding, left: 0,
                                               bottom: -Constants.ProductCellLayout.PriceButtonHitTestSlopPadding, right: 0)
        
        let iconCenterLayout = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: checkIconNode)
        let priceWithIconBackgroundLayout = ASBackgroundLayoutSpec(child: priceButton, background: iconCenterLayout)
        let priceButtonLayout = ASInsetLayoutSpec(insets: Constants.ProductCellLayout.PriceButtonInsets, child: priceWithIconBackgroundLayout)
        
        layout.children?.append(priceButtonLayout)
        
        return layout
    }    
}
