import Foundation
import AsyncDisplayKit
import pop
import SwiftEventBus

protocol SelectAddressViewControllerDelegate: class {
    func selectAddressViewController(_ vc: SelectAddressViewController, didSelectAddress address: Address)
    
    func selectAddressViewControllerDapTapAddAddressButton(_ vc: SelectAddressViewController)
    
    func selectAddressViewControllerDidTapBackButton(_ vc: SelectAddressViewController)        
}


class SelectAddressViewController: ASViewController<SelectAddressNode> {
    weak var delegate: SelectAddressViewControllerDelegate?
    
    var isEditMode = false {
        didSet {
            guard isEditMode != oldValue else { return }
            
            adjustNodes()
        }
    }
    
    fileprivate var navbarNode: SelectAddressNavbarNode {
        return node.navbarNode
    }
    
    fileprivate var collectionNode: ASCollectionNode {
        return node.collectionNode
    }
    
    fileprivate var addresses: [Address] {
        return []
//        return Array(userSettings.addresses.filter({$0.locality == userSettings.menu!.locality})).sorted(by: <)
    }
    
    var addressesCount: Int {
        return self.addresses.count
    }
    
    convenience init() {
        self.init(node: SelectAddressNode())
        
        self.node.automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionNode.reloadData()
        
        EventBus.onMainThread(self, name: DidRemoveAddressEvent.name) { [unowned self] _ in
            self.collectionNode.reloadData()
            
            self.adjustCollectionNode(withAnimation: false)
            
            self.isEditMode = !self.addresses.isEmpty
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        EventBus.unregister(self)
    }
    
    private func setupNodes() {
        self.navbarNode.delegate = self
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
    }
    
    fileprivate func adjustNodes(withAnimation: Bool = true) {
        navbarNode.editButtonNode.isSelected = isEditMode
        
        adjustCollectionNode(withAnimation: withAnimation)
    }
    
    fileprivate func adjustCollectionNode(withAnimation: Bool) {
        for i in 0..<addresses.count {
            let indexPath = IndexPath(item: i, section: 0)
            
            if let addressCellNode = collectionNode.nodeForItem(at: indexPath) as? AddressCellNode {
                addressCellNode.mapMarkerTextNode.isHidden = isEditMode
                addressCellNode.removeButtonNode.isHidden = !isEditMode
                addressCellNode.editButtonNode.isHidden = !isEditMode
                
                if(withAnimation) {
                    playAddressCellAnimationOnModeChange(addressCellNode)
                }
            }
        }
    }
    
    private func playAddressCellAnimationOnModeChange(_ addressCellNode: AddressCellNode) {
        if isEditMode {
            addressCellNode.removeButtonNode.titleNode.pop_add(createIconImpulseAnimation(), forKey: "ImpulseAnimation")
            addressCellNode.editButtonNode.titleNode.pop_add(createIconImpulseAnimation(), forKey: "ImpulseAnimation")
            
        } else {
            addressCellNode.mapMarkerTextNode.pop_add(createIconImpulseAnimation(), forKey: "ImpulseAnimation")
        }
    }
}

extension SelectAddressViewController: SelectAddressNavbarDelegate {
    func selectAddressNavbarDidTapBackButton(node: SelectAddressNavbarNode) {
        delegate?.selectAddressViewControllerDidTapBackButton(self)
    }
    
    func selectAddressNavbarDidTapEditButton(node: SelectAddressNavbarNode) {
        isEditMode = !isEditMode
    }
}


extension SelectAddressViewController: ASCollectionDelegate, ASCollectionDataSource {
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return self.addressesCount + 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        if indexPath.row > addressesCount {
            return ASSizeRangeZero
        }
        
        let maxWidth = UIScreen.main.bounds.width - 2 * 16
        
        if indexPath.row == addressesCount {
            return ASSizeRangeMake(CGSize(width: 0, height: 0), CGSize(width: maxWidth, height: 44))
        }
        
        let addressLabelHeight = calculateAddressLabelHeight(addresses[indexPath.row], width: maxWidth)
        let maxHeight = mapImageHeight + addressLabelHeight + AddressCellNode.InsetBottom
        
        return ASSizeRangeMake(CGSize(width: 0, height: 0), CGSize(width: maxWidth, height: maxHeight))
    }
    
    private var mapImageHeight: CGFloat {
        return AddressCellNode.calculateMapImageSize().height
    }
    
    private func calculateAddressLabelHeight(_ address: Address, width: CGFloat) -> CGFloat {
        return address.displayName.computeHeight(attributes: AddressCellNode.LabelStringAttributes, width: width)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        if indexPath.row > addressesCount {
            return { ASCellNode() }
        }
        
        if indexPath.row == addressesCount {
            return { AddAddressCellNode() }
        }
        
        return { AddressCellNode(address: self.addresses[indexPath.row]) }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row > addressesCount {
            return
        }
        
        if indexPath.row == addressesCount {
            isEditMode = false
            delegate?.selectAddressViewControllerDapTapAddAddressButton(self)
            return
        }
            
        if !isEditMode {
            delegate?.selectAddressViewController(self, didSelectAddress: addresses[indexPath.row])
        }
    }
}

class SelectAddressNode: ASDisplayNode {
    fileprivate let navbarNode = SelectAddressNavbarNode()
    fileprivate let collectionNode: ASCollectionNode
    
    override init() {
        collectionNode = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
        
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        setupNodes()        
    }

    func reloadCollection() {
        DispatchQueue.main.async { [unowned self] _ in
            self.collectionNode.reloadData()
        }
    }
    
    override func setNeedsLayout() {
        reloadCollection()
        super.setNeedsLayout()
    }
    
    override func didLoad() {
        super.didLoad()
        
        collectionNode.view.contentInset = UIEdgeInsets(top: 88, left: 16, bottom: 16, right: 16)
        collectionNode.view.showsVerticalScrollIndicator = false
        collectionNode.view.showsHorizontalScrollIndicator = false
    }
    
    private func setupNodes() {
        self.navbarNode.title = "Куда доставить?"
        self.collectionNode.allowsSelection = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.collectionNode.style.preferredSize = constrainedSize.max
        
        return ASOverlayLayoutSpec(child: self.collectionNode, overlay: self.navbarNode)
    }
}

extension SelectAddressViewController {
    func createIconImpulseAnimation() -> POPSpringAnimation {
        let toValue: Point = (1,1)
        let fromValue: Point = (0.95, 0.95)
        let result = POPSpringAnimation.viewScaleXY(
            toValue: toValue,
            fromValue: fromValue,
            bounciness: PaperButton.IconImpulseBounciness,
            velocity: PaperButton.IconImpulseVelocity)
        
        return result
    }
}
