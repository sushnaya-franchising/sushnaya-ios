import Foundation
import AsyncDisplayKit
import pop


class CheckoutViewController: ASViewController<CheckoutContentNode> {
    
    fileprivate var orderVC: OrderViewController!
    fileprivate var editAddressVC: EditAddressViewController!
    fileprivate var selectAddressVC: SelectAddressViewController!
    
    fileprivate var tapRecognizer: UITapGestureRecognizer!
    fileprivate var keyboardHeight: CGFloat = 0
    
    fileprivate var addresses: [Address] {
        return []
    }        
    
    convenience init() {
        let editAddressVC = EditAddressViewController()
        let selectAddressVC = SelectAddressViewController()
        let orderVC = OrderViewController()
        
        self.init(node: CheckoutContentNode(orderNode: orderVC.node,
                                            editAddressNode: editAddressVC.node,
                                            selectAddressNode: selectAddressVC.node))
        
        self.orderVC = orderVC
        self.orderVC.delegate = self
        
        self.editAddressVC = editAddressVC
        self.editAddressVC.delegate = self
        
        self.selectAddressVC = selectAddressVC
        self.selectAddressVC.delegate = self
        
        self.tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))
        self.tapRecognizer.numberOfTapsRequired = 1
        
        self.node.automaticallyManagesSubnodes = true
        
        updateState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        EventBus.onMainThread(self, name: ShowEditAddressViewControllerEvent.name) { [unowned self] (notification) in
            self.editAddressVC.addressToEdit = (notification.object as! ShowEditAddressViewControllerEvent).address
            self.node.state = .editAddress
            self.node.transitionLayout(withAnimation: true, shouldMeasureAsync: false)
        }
        
        EventBus.onMainThread(self, name: DidCreateAddressEvent.name) { [unowned self] _ in
            self.node.state = .order
            self.node.transitionLayout(withAnimation: true, shouldMeasureAsync: false)
        }
        
        EventBus.onMainThread(self, name: DidUpdateAddressEvent.name) { [unowned self] (notification) in
            self.node.state = .order
            self.node.transitionLayout(withAnimation: true, shouldMeasureAsync: false)
        }
        
//        EventBus.onMainThread(self, name: DidRemoveAddressEvent.name) { [unowned self] (notification) in
//            if self.addresses.isEmpty {
//                self.node.state = .editAddress
//                self.node.transitionLayout(withAnimation: true, shouldMeasureAsync: false)
//            }
//        }
        
        updateState()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        EventBus.unregister(self)
    }
    
    func updateState() {
        if addresses.isEmpty {
            self.node.state = .editAddress
            editAddressVC.node.setNeedsLayout()
            
        } else {
            self.node.state = .selectAddress
            selectAddressVC.node.setNeedsLayout()
        }
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {        
        self.view.endEditing(true)
    }
}

extension CheckoutViewController: EditAddressViewControllerDelegate {
    func editAddressViewControllerDidTapBackButton(_ vc: EditAddressViewController) {
        if addresses.isEmpty {
            self.dismiss(animated: true)
            
        } else {
            self.node.state = .selectAddress
            node.transitionLayout(withAnimation: true, shouldMeasureAsync: false)
        }
    }        
}

extension CheckoutViewController: SelectAddressViewControllerDelegate {
    func selectAddressViewControllerDidTapBackButton(_ vc: SelectAddressViewController) {
        self.dismiss(animated: true)
    }

    func selectAddressViewControllerDapTapAddAddressButton(_ vc: SelectAddressViewController) {
        editAddressVC.addressToEdit = nil
        node.state = .editAddress
        node.transitionLayout(withAnimation: true, shouldMeasureAsync: false)
    }
    
    func selectAddressViewController(_ vc: SelectAddressViewController, didSelectAddress address: Address) {
        // todo: pass selected address to the order node
        self.node.state = .order
        node.transitionLayout(withAnimation: true, shouldMeasureAsync: false)
    }        
}

extension CheckoutViewController: OrderViewControllerDelegate {
    func orderViewControllerDidTapBackButton(_ vc: OrderViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func orderViewController(_ vc: OrderViewController, didSubmitOrder order: NSObject?) {
        // todo: implement order view controller did submit order
    }
}

enum CheckoutContentNodeState {
    case order, editAddress, selectAddress
}

class CheckoutContentNode: ASDisplayNode {
    fileprivate var orderNode: OrderNode!
    fileprivate var editAddressNode: EditAddressContentNode!
    fileprivate var selectAddressNode: SelectAddressNode!
    fileprivate var state: CheckoutContentNodeState = .editAddress {
        didSet {
            guard state != oldValue else { return }
            
            self.setNeedsLayout()
        }
    }
        
    init(orderNode: OrderNode, editAddressNode: EditAddressContentNode, selectAddressNode: SelectAddressNode) {
        super.init()
        self.orderNode = orderNode
        self.editAddressNode = editAddressNode
        self.selectAddressNode = selectAddressNode
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
        let pusherHeight: CGFloat = 78
        pusher.style.height = ASDimension(unit: .points, value: pusherHeight)
        
        let contentSize = CGSize(width: constrainedSize.max.width,
                                 height: constrainedSize.max.height - pusherHeight)
        
        let contentNode: ASDisplayNode!
        
        if self.state == .order {
            contentNode = self.orderNode
            
        } else if self.state == .editAddress {
            contentNode = self.editAddressNode
            
        } else {
            contentNode = self.selectAddressNode
        }
        
        contentNode.style.preferredSize = contentSize
        
        layout.children = [pusher, contentNode]
        
        return layout
    }
    
//    override func animateLayoutTransition(_ context: ASContextTransitioning) {
//        if self.state == order {
//            let initialOrderFrame = contextorderFrame(for: editAddressNode)
//            orderNode.frame = initialOrderFrame
//            
//            var finalEditAddressFrame = context.finalFrame(for: orderNode)
//            finalEditAddressFrame.origin.x -= finalEditAddressFrame.size.width
//            
//            // todo: use pop to animate transitioning
//            UIView.animate(withDuration: 0.4, animations: {
//                self.orderNode.frame = context.finalFrame(for: self.orderNode)
//                self.editAddressNode.frame = finalEditAddressFrame
//            }, completion: { finished in
//                context.completeTransition(finished)
//            })
//            
//        } else {
//            var initialEditAddressFrame = contextorderFrame(for: orderNode)
//            initialEditAddressFrame.origin.x += initialEditAddressFrame.size.width
//            
//            editAddressNode.frame = initialEditAddressFrame
//            
//            var finalOrderFrame = context.finalFrame(for: editAddressNode)
//            finalOrderFrame.origin.x -= finalOrderFrame.size.width
//            
//            UIView.animate(withDuration: 0.4, animations: {
//                self.editAddressNode.frame = context.finalFrame(for: self.editAddressNode)
//                self.orderNode.frame = finalOrderFrame
//            }, completion: { finished in
//                context.completeTransition(finished)
//            })
//        }
//    }
}
