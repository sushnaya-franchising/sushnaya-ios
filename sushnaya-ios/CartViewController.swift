import Foundation
import AsyncDisplayKit

class CartViewController: ASViewController<ASDisplayNode> {

    fileprivate var checkoutVC: CheckoutViewController!
    fileprivate var cartNode: CartNode!
    
    var cart: Cart {
        return app.cart
    }    
    
    fileprivate let presentationManager = SlidePresentationManager()
    
    convenience init() {
        self.init(node: ASDisplayNode())

        setupCartNode()

        self.node.automaticallyManagesSubnodes = true
        self.node.layoutSpecBlock = { [unowned self] _ in
            return ASWrapperLayoutSpec(layoutElement: self.cartNode)
        }

        EventBus.onMainThread(self, name: DidRemoveFromCartEvent.name) { [unowned self] (notification) in
            if self.cart.isEmpty {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    private func setupCartNode() {
        cartNode = CartNode(cart: cart)
        cartNode.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cartNode.setNeedsLayout()
        cartNode.cartContentNode.setNeedsLayout()
        cartNode.cartContentNode.toolBarNode.setNeedsLayout()
        cartNode.cartContentNode.cartItemsTableNode.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        cartNode.cartContentNode.bindEventHandlers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cartNode.cartContentNode.unbindEventHandler()
    }

    fileprivate func showCheckoutViewController() {
        if checkoutVC == nil {
            checkoutVC = CheckoutViewController()
            checkoutVC.transitioningDelegate = presentationManager
            checkoutVC.modalPresentationStyle = .custom
            
            presentationManager.interactionController.destinationVC = checkoutVC
        }

        show(checkoutVC, sender: self)
    }
}

extension CartViewController: CartNodeDelegate {
    func cartNodeDidTouchUpInsideCloseButton() {
        dismiss(animated: true, completion: nil)
    }

    func cartNodeDidTouchUpInsideOrderWithDeliveryButton() {
        showCheckoutViewController()
    }
}
