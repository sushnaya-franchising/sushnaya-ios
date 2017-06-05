//
//  OrderWithDeliveryViewController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 5/15/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop

class OrderViewController: ASViewController<ASDisplayNode> {
    
    fileprivate let tableNode = ASTableNode()
    fileprivate let navbarNode = OrderNavbarNode()
    
    fileprivate var tapRecognizer: UITapGestureRecognizer!
    fileprivate var keyboardHeight: CGFloat = 0
    
    convenience init() {
        self.init(node: ASDisplayNode())
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))
        tapRecognizer.numberOfTapsRequired = 1
        
        self.node.backgroundColor = PaperColor.White
        self.node.automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    private func setupNodes() {
        self.navbarNode.delegate = self
        self.navbarNode.title = "Заказ с доставкой"
        tableNode.delegate = self
        tableNode.dataSource = self
        tableNode.allowsSelection = false
        tableNode.view.separatorStyle = .none
        
        self.node.layoutSpecBlock = { [unowned self] _ in
            return ASOverlayLayoutSpec(child: self.tableNode, overlay: self.navbarNode)
        }
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {        
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableNode.view.showsVerticalScrollIndicator = false
        tableNode.view.showsHorizontalScrollIndicator = false
        
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
        self.dismiss(animated: true, completion: nil)        
        self.view.endEditing(true)
    }
}

extension OrderViewController: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { [unowned self] _ in
            OrderWithDeliveryFormNode(cart: self.app.userSession.cart)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
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
