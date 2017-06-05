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

//class OrderWithDeliveryFormNode: ASCellNode {
//    static let SectionTitleStringAttributes = [
//        NSForegroundColorAttributeName: PaperColor.Gray,
//        NSFontAttributeName: UIFont.systemFont(ofSize: 14)
//    ]
//
//    let cart: Cart
//    
//    let textNodeOne = ASTextNode()
//    let textNodeTwo = ASTextNode()
//    let buttonNode = ASButtonNode()
//    
//    var enabled = false
//    
//    init(cart: Cart) {
//        self.cart = cart
//        super.init()
//        self.backgroundColor = PaperColor.Gray100
//        self.automaticallyManagesSubnodes = true
//        setupNodes()
//    }
//    
//    private func setupNodes() {
//        textNodeOne.attributedText = NSAttributedString(string: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled")
//        textNodeTwo.attributedText = NSAttributedString(string: "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English.")
//        
//        buttonNode.setAttributedTitle(NSAttributedString.attributedString(string: "Start Layout Transition", fontSize: 16, color: PaperColor.Blue), for: .normal)
//        buttonNode.setAttributedTitle(NSAttributedString.attributedString(string: "Start Layout Transition", fontSize: 16, color: PaperColor.Blue.withAlphaComponent(0.5)), for: .highlighted)
//        
//        textNodeOne.backgroundColor = PaperColor.Orange
//        textNodeTwo.backgroundColor = PaperColor.Green
//    }
//    
//    override func didLoad() {
//        super.didLoad()
//        
//        buttonNode.setTargetClosure { [unowned self] _ in
//            self.enabled = !self.enabled
//            self.transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
//        }
//    }
//    
//    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
//        let nextTextNode = self.enabled ? self.textNodeTwo : self.textNodeOne
//        nextTextNode.style.flexGrow = 1
//        nextTextNode.style.flexShrink = 1
//        
//        let horizontalStackLayout = ASStackLayoutSpec.horizontal()
//        horizontalStackLayout.children = [nextTextNode]
//        
//        self.buttonNode.style.alignSelf = .center
//        
//        let verticalStackLayout = ASStackLayoutSpec.vertical()
//        verticalStackLayout.spacing = 10
//        verticalStackLayout.children = [horizontalStackLayout, self.buttonNode]
//        
//        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(16, 16, 16, 16), child: verticalStackLayout)
//    }
//}

protocol OrderWithDeliveryFormDelegate: class {
    func orderWithDeliveryFormDidSubmit(_ node: OrderWithDeliveryFormNode)
}

class OrderWithDeliveryFormNode: ASCellNode {

    static let SectionTitleStringAttributes = [
        NSForegroundColorAttributeName: PaperColor.Gray,
        NSFontAttributeName: UIFont.systemFont(ofSize: 14)
    ]
    
    weak var delegate: OrderWithDeliveryFormDelegate?        
    
    fileprivate var addressSectionNode = OrderFormAddressSectionNode()
    fileprivate var paymentSectionNode = OrderFormPaymentSectionNode()
    
    fileprivate var optionalSectionNode = OrderFormOptionalSectionNode()
    fileprivate var summarySectionNode: OrderFormSummarySectionNode
    fileprivate var submitButtonNode = ASButtonNode()        
    
    let cart: Cart
    
    init(cart: Cart) {
        self.cart = cart
        self.summarySectionNode = OrderFormSummarySectionNode(cart: cart)
        super.init()
        self.automaticallyManagesSubnodes = true
        setupNodes()

    }
    
    private func setupNodes() {
        setupSubmitButtonNode()
        setupPaymentSectionNode()
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
    
    private func setupPaymentSectionNode() {
        paymentSectionNode.delegate = self
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
        self.paymentSectionNode.setNeedsLayout()
        self.invalidateCalculatedLayout()
    }
}

