//
//  OrderFormPaymentSectionNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 5/17/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop

enum PaymentType {
    case cash, cardToCourier
}

protocol OrderFormPaymentSectionDelegate: class {
    func orderFormPaymentSection(_ node: OrderFormPaymentSectionNode, didChangePaymentTypeTo paymentType: PaymentType)
}

class OrderFormPaymentSectionNode: ASDisplayNode {
    fileprivate var titleTextNode = ASTextNode()
    fileprivate let segmentedControl = SegmentedControlNode()
    
    weak var delegate: OrderFormPaymentSectionDelegate?
    
    var paymentType = PaymentType.cash {
        didSet {
            guard oldValue != paymentType else { return }
            
            delegate?.orderFormPaymentSection(self, didChangePaymentTypeTo: paymentType)
        }
    }
    
    override init() {
        super.init()        
        self.automaticallyManagesSubnodes = true
        setupNodes()
    }
    
    private func setupNodes() {
        setupTitleTextNode()
        setupSegmentedControlNode()
    }
    
    private func setupTitleTextNode() {
        let title = NSAttributedString(string: "Способ оплаты".uppercased(), attributes: OrderWithDeliveryFormNode.SectionTitleStringAttributes)
        titleTextNode.attributedText = title
    }
    
    private func setupSegmentedControlNode() {
        segmentedControl.backgroundColor = PaperColor.Gray200.withAlphaComponent(0.95)
        segmentedControl.delegate = self
        
        let cashButton = ASButtonNode()
        let cashButtonTitle = NSAttributedString.attributedString(string: "Наличными", fontSize: 14, color: PaperColor.Gray800)
        cashButton.setAttributedTitle(cashButtonTitle, for: .normal)
        segmentedControl.addButton(cashButton)
        
        let bankCardButton = ASButtonNode()
        let bankCardButtonTitle = NSAttributedString.attributedString(string: "Картой курьеру", fontSize: 14, color: PaperColor.Gray800)
        bankCardButton.setAttributedTitle(bankCardButtonTitle, for: .normal)
        segmentedControl.addButton(bankCardButton)
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.segmentedControl.cornerRadius = 11
        self.segmentedControl.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let titleLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 16, 0, 0), child: titleTextNode)
        
        segmentedControl.style.maxHeight = ASDimension(unit: .points, value: 44)
        let segmentedControlLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(24, 16, 0, 16), child: segmentedControl)
        
        let segmentedControlRow = ASStackLayoutSpec.horizontal()
        segmentedControlRow.alignItems = .start
        segmentedControlRow.justifyContent = .center
        segmentedControlRow.children = [segmentedControlLayout]
            
        let stackLayout = ASStackLayoutSpec.vertical()
        stackLayout.children = [titleLayout, segmentedControlRow]
        
        return stackLayout
    }
}

extension OrderFormPaymentSectionNode: SegmentedControlDelegate {
    func segmentedControl(segmentedControl: SegmentedControlNode, didSelectSegment segment: Int) {
        switch segment {
        case 0:
            paymentType = .cash
        default:
            paymentType = .cardToCourier
        }
    }
}
