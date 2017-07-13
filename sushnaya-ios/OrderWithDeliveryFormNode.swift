//
//  OrderWithDeliveryFormNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 5/17/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop


protocol OrderWithDeliveryFormDelegate: class {
    func orderWithDeliveryFormDidSubmit(_ node: OrderWithDeliveryFormNode)
    
    func orderWithDeliveryForm(_ node: OrderWithDeliveryFormNode, didChangePaymentTypeTo paymentType: PaymentType)
}

class OrderWithDeliveryFormNode: ASCellNode {

    static let SectionTitleStringAttributes = [
        NSForegroundColorAttributeName: PaperColor.Gray,
        NSFontAttributeName: UIFont.systemFont(ofSize: 14)
    ]
    
    weak var delegate: OrderWithDeliveryFormDelegate?    
    
    fileprivate let addressSectionNode = OrderFormAddressSectionNode()
    fileprivate let paymentSectionNode = OrderFormPaymentSectionNode()
    fileprivate let cashOptionsSectionNode: CashOptionsSectionNode
    
    fileprivate let optionalSectionNode = OrderFormOptionalSectionNode()
    fileprivate let summarySectionNode: OrderFormSummarySectionNode
    fileprivate let submitButtonNode = ASButtonNode()
    
    fileprivate var userSession: UserSession
    fileprivate var cart: Cart {
        return self.userSession.cart
    }
    fileprivate var addresses: [Address]? {
        return self.userSession.settings.addresses
    }
    
    init(userSession: UserSession) {
        self.userSession = userSession
        self.summarySectionNode = OrderFormSummarySectionNode(cart: userSession.cart)
        self.cashOptionsSectionNode = CashOptionsSectionNode(cart: userSession.cart)
        
        super.init()
        self.automaticallyManagesSubnodes = true
        setupNodes()        
    }
    
    private func setupNodes() {
        setupAddressSectionNode()
        setupSubmitButtonNode()
        setupPaymentSectionNode()
    }
    
    private func setupAddressSectionNode() {
        addressSectionNode.addresses = self.addresses
    }
    
    private func setupPaymentSectionNode() {
        paymentSectionNode.delegate = self
    }
    
    private func setupSubmitButtonNode() {
        let title = NSAttributedString(string: "Отправить заказ", attributes: [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
        ])
        submitButtonNode.setAttributedTitle(title, for: .normal)
        submitButtonNode.backgroundColor = PaperColor.Gray300
        submitButtonNode.setTargetClosure { [unowned self] _ in
            self.view.endEditing(true)
            
            // todo: validate
            
            self.delegate?.orderWithDeliveryFormDidSubmit(self)
        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        submitButtonNode.cornerRadius = 11
        submitButtonNode.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var rows = [ASLayoutElement]()
        rows.append(self.addressSectionNode)
        
        self.paymentSectionNode.style.flexGrow = 1
        self.paymentSectionNode.style.flexShrink = 1
        rows.append(self.paymentSectionNode)
        
        if(self.paymentSectionNode.paymentType == .cash) {
            rows.append(cashOptionsSectionNode)
        }
        
        rows.append(self.optionalSectionNode)
        
        let spacer = ASLayoutSpec()
        spacer.style.flexGrow = 1
        spacer.style.flexShrink = 1
        rows.append(spacer)
        
        rows.append(self.summarySectionNode)
        
        self.submitButtonNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 44)
        rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(-16, 16, 16, 16), child: self.submitButtonNode))
        
        let layout = ASStackLayoutSpec.vertical()
        layout.spacing = 32
        layout.children = rows
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(88, 0, 0, 0), child: layout)
    }
}


extension OrderWithDeliveryFormNode: OrderFormPaymentSectionDelegate {
    func orderFormPaymentSection(_ node: OrderFormPaymentSectionNode, didChangePaymentTypeTo paymentType: PaymentType) {
        self.delegate?.orderWithDeliveryForm(self, didChangePaymentTypeTo: paymentType)
    }
}
