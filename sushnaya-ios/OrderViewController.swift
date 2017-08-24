//
//  OrderViewController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 8/24/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop


protocol OrderViewControllerDelegate: class {
    func orderViewController(_ vc: OrderViewController, didSubmitOrder order: NSObject?)
    
    func orderViewControllerDidTapBackButton(_ vc: OrderViewController)
}


class OrderViewController: ASViewController<OrderNode> {
    
    weak var delegate: OrderViewControllerDelegate?
    
    fileprivate var tapRecognizer: UITapGestureRecognizer!
    fileprivate var keyboardHeight: CGFloat = 0
    
    fileprivate var navbarNode: OrderNavbarNode {
        return node.navbarNode
    }
    
    fileprivate var tableNode: ASTableNode {
        return node.tableNode
    }
    
    fileprivate var addresses: [Address] {
        return self.app.userSession.settings.addresses
    }
    
    convenience init() {
        self.init(node: OrderNode())
        
        self.tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))
        self.tapRecognizer.numberOfTapsRequired = 1
        
        self.node.automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    private func setupNodes() {
        self.navbarNode.delegate = self
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
}

extension OrderViewController: OrderNavbarDelegate {
    func orderNavbarDidTapBackButton(node: OrderNavbarNode) {
        self.view.endEditing(true)
        delegate?.orderViewControllerDidTapBackButton(self)
    }
}

extension OrderViewController: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { [unowned self] _ in
            let node = OrderWithDeliveryFormNode(userSession: self.app.userSession)
            node.delegate = self
            
            return node
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

extension OrderViewController: OrderWithDeliveryFormDelegate {
    func orderWithDeliveryFormDidSubmit(_ node: OrderWithDeliveryFormNode) {
        // todo: implement
        delegate?.orderViewController(self, didSubmitOrder: nil)
    }
    
    func orderWithDeliveryForm(_ node: OrderWithDeliveryFormNode, didChangePaymentTypeTo paymentType: PaymentType) {
        node.transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
    }
}

extension OrderViewController {
    
    var notificationCenter: NotificationCenter {
        return NotificationCenter.default
    }
    
    func subscribeToKeyboardNotifications() {
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                       name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                       name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.keyboardHeight = getKeyboardHeight(notification: notification)
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.keyboardHeight, right: 0)
        
        tableNode.view.contentInset = contentInsets
        tableNode.view.scrollIndicatorInsets = contentInsets
        
        adjustScrollNodeOffset()
    }
    
    func adjustScrollNodeOffset() {
        if  let view = getFirstResponderAsFormFieldView(),
            let originY = view.superview?.convert(view.frame.origin, to: nil).y {
            let destOriginY:CGFloat = 72 //self.navbarBackgroundNode.bounds.height // todo: move navbar height to constants
            let maxOffsetY = tableNode.view.contentSize.height - (self.view.bounds.height - keyboardHeight)
            let delta = (destOriginY + view.bounds.height) - (self.view.bounds.height - keyboardHeight)
            
            if delta > 0 {
                let offsetY = min(tableNode.view.contentOffset.y + (originY - destOriginY) + delta, maxOffsetY)
                tableNode.view.contentOffset = CGPoint(x: 0, y: offsetY)
                
            } else {
                let offsetY = min(tableNode.view.contentOffset.y + (originY - destOriginY), maxOffsetY)
                tableNode.view.contentOffset = CGPoint(x:0, y: offsetY)
            }
        }
    }
    
    fileprivate func getFirstResponderAsFormFieldView() -> UIView? {
        guard let view = self.view.currentFirstResponder() as? UIView else {
            return nil
        }
        
        return view.superview?.superview
    }
    
    func keyboardWillHide(notification: NSNotification) {
        tableNode.view.contentInset = .zero
        tableNode.view.scrollIndicatorInsets = .zero
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
    }
}

class OrderNode: ASDisplayNode {
    fileprivate let tableNode = ASTableNode()
    fileprivate let navbarNode = OrderNavbarNode()
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    func setupNodes() {
        self.navbarNode.title = "Заказ с доставкой"
        
        self.tableNode.allowsSelection = false
    }
    
    override func didLoad() {
        super.didLoad()
        
        tableNode.view.showsVerticalScrollIndicator = false
        tableNode.view.showsHorizontalScrollIndicator = false
        tableNode.view.separatorStyle = .none
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASOverlayLayoutSpec(child: self.tableNode, overlay: self.navbarNode)
    }
}
