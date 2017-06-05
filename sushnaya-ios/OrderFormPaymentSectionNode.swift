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
    
    let textNodeOne = ASTextNode()
    
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
        setupDummy()
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
    
    private func setupDummy() {
        textNodeOne.attributedText = NSAttributedString.init(string: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled")
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
        
        var rows = [titleLayout, segmentedControlRow]
        
        if paymentType == .cash {
            let textNodeLayout =  ASInsetLayoutSpec(insets: UIEdgeInsetsMake(16, 16, 16, 16), child: textNodeOne)
            
            textNodeLayout.style.flexShrink = 1
            textNodeLayout.style.flexGrow = 1
        
            let horizontalStack = ASStackLayoutSpec.horizontal()
            horizontalStack.children = [textNodeLayout]
            rows.append(horizontalStack)
        }
            
        let stackLayout = ASStackLayoutSpec.vertical()
        stackLayout.children = rows
        
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
