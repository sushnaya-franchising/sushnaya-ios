import Foundation
import AsyncDisplayKit
import pop
import SwiftEventBus
import CoreStore

protocol SelectAddressViewControllerDelegate: class {
    func selectAddressViewController(_ vc: SelectAddressViewController, didSelectAddress address: AddressEntity)
    
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
    
    fileprivate var addresses: ListMonitor<AddressEntity> {
        return app.core.addressesByLocality
    }
    
    fileprivate var addressesCount: Int {
        return addresses.objectsInAllSections().count
    }
    
    fileprivate var noAddresses: Bool {
        return addressesCount == 0
    }
    
    convenience init() {
        self.init(node: SelectAddressNode())
        
        self.node.automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FoodServiceRest.requestAddresses(authToken: app.authToken!,
                                         localityId: app.selectedMenu?.locality.serverId)
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
        
        adjustCollectionNode()
    }
    
    fileprivate func adjustCollectionNode() {
        for i in 0..<addressesCount {
            let indexPath = IndexPath(item: i, section: 0)
            
            if let addressCellNode = collectionNode.nodeForItem(at: indexPath) as? AddressCellNode {
                addressCellNode.mapMarkerTextNode.isHidden = isEditMode
                addressCellNode.removeButtonNode.isHidden = !isEditMode
                addressCellNode.editButtonNode.isHidden = !isEditMode
                
                playAddressCellAnimationOnModeChange(addressCellNode)
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
    
    fileprivate func setCollectionEnabled(_ enabled: Bool) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .beginFromCurrentState,
            animations: { () -> Void in
                self.collectionNode.alpha = enabled ? 1.0 : 0.5
                self.collectionNode.isUserInteractionEnabled = enabled
        })
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

extension SelectAddressViewController: ListSectionObserver {
    
    func listMonitorWillChange(_ monitor: ListMonitor<AddressEntity>) {
        collectionNode.view.beginUpdates()
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<AddressEntity>) {
        collectionNode.view.endUpdates(animated: true)
    }
    
    func listMonitorWillRefetch(_ monitor: ListMonitor<AddressEntity>) {
        setCollectionEnabled(false)
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<AddressEntity>) {
        collectionNode.reloadData()

        setCollectionEnabled(true)
    }
    
    func listMonitor(_ monitor: ListMonitor<AddressEntity>, didInsertObject object: AddressEntity, toIndexPath indexPath: IndexPath) {
        
        collectionNode.insertItems(at: [indexPath])
    }
    
    func listMonitor(_ monitor: ListMonitor<AddressEntity>, didDeleteObject object: AddressEntity, fromIndexPath indexPath: IndexPath) {
        collectionNode.deleteItems(at: [indexPath])
        
        isEditMode = self.addressesCount > 0
    }
    
    func listMonitor(_ monitor: ListMonitor<AddressEntity>, didUpdateObject object: AddressEntity, atIndexPath indexPath: IndexPath) {
        
        if let cell = collectionNode.nodeForItem(at: indexPath) as? AddressCellNode {
            cell.address = addresses.objectsInSection(indexPath.section)[indexPath.row]
        }
    }
    
    func listMonitor(_ monitor: ListMonitor<AddressEntity>, didMoveObject object: AddressEntity, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        
        collectionNode.deleteItems(at: [fromIndexPath])
        collectionNode.insertItems(at: [toIndexPath])
    }
    
    // MARK: ListSectionObserver
    
    func listMonitor(_ monitor: ListMonitor<AddressEntity>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        collectionNode.insertSections(IndexSet(integer: sectionIndex))
    }
    
    func listMonitor(_ monitor: ListMonitor<AddressEntity>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        collectionNode.deleteSections(IndexSet(integer: sectionIndex))
        
        isEditMode = self.addressesCount > 0
    }
}

// todo: support sections with cities headers
// todo: address entity mappings
// todo: edit address vcs
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
    
    private func calculateAddressLabelHeight(_ address: AddressEntity, width: CGFloat) -> CGFloat {
        return address.displayName.calculateHeight(attributes: AddressCellNode.LabelStringAttributes, width: width)
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
