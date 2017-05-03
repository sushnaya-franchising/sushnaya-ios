//
//  AddressMapCalloutNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/30/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

public enum AddressMapCalloutState {
    case addressIsDefined(String)
    case addressIsUndefined
    case forceDeliveryPoint
    case outOfDeliveryZone
    case loading
}

public func !=(lhs: AddressMapCalloutState, rhs: AddressMapCalloutState) -> Bool {
    return !(lhs == rhs)
}

public func ==(lhs: AddressMapCalloutState, rhs: AddressMapCalloutState) -> Bool {
    switch(lhs, rhs) {
    case let (.addressIsDefined(a), .addressIsDefined(b)):
        return a == b
        
    case (.addressIsUndefined, .addressIsUndefined),
         (.forceDeliveryPoint, .forceDeliveryPoint),
         (.outOfDeliveryZone, .outOfDeliveryZone),
         (.loading, .loading):
        return true
        
    default:
        return false
    }
}

class AddressMapCalloutNode: ASDisplayNode {
    
    fileprivate let addressDetermining = "Определение адреса ..."
    fileprivate let forceDeliveryPoint = "Доставить в указанную точку?"
    fileprivate let addressIsUndefined = "Адрес не определен. Доставить в указанную точку?"
    fileprivate let outOfDeliveryZone = "Вне зоны доставки"
    
    fileprivate let headerTextNode = ASTextNode()
    fileprivate let addressTextNode = ASTextNode()
    fileprivate let submitButtonNode = ASButtonNode()
    fileprivate let separator = ASDisplayNode()
    fileprivate var activityIndicatorNode: ASDisplayNode?
    
    var state: AddressMapCalloutState = .loading {
        didSet {
            guard state != oldValue else {
                return
            }
            
            setupNodes()
            setNeedsLayout()
        }
    }
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupHeaderTextNode()        
        setupAddressTextNode()
        setupDelimiterLineNode()
        setupSubmitButtonNode()
        setupActivityIndicatorNode()
    }
    
    private func setupHeaderTextNode() {
        headerTextNode.attributedText = NSAttributedString.attributedString(string: "Адрес доставки", fontSize: 14, color: PaperColor.Gray800)
        headerTextNode.isHidden = state == .outOfDeliveryZone
    }
    
    private func setupAddressTextNode() {
        switch state {
        case let .addressIsDefined(address):
            addressTextNode.attributedText = NSAttributedString.attributedString(string: address, fontSize: 12, color: PaperColor.Gray700, bold: false)
        case .addressIsUndefined:
            addressTextNode.attributedText = NSAttributedString.attributedString(string: addressIsUndefined, fontSize: 12, color: PaperColor.Gray700, bold: false)
        case .forceDeliveryPoint:
            addressTextNode.attributedText = NSAttributedString.attributedString(string: forceDeliveryPoint, fontSize: 12, color: PaperColor.Gray700, bold: false)
        case .loading:
            addressTextNode.attributedText = NSAttributedString.attributedString(string: addressDetermining, fontSize: 12, color: PaperColor.Gray700, bold: false)
        default:
            break
        }
        
        addressTextNode.isHidden = state == .outOfDeliveryZone
    }
    
    private func setupDelimiterLineNode() {
        separator.backgroundColor = PaperColor.Gray300
        separator.isHidden = state == .outOfDeliveryZone
    }
    
    private func setupSubmitButtonNode() {
        submitButtonNode.setAttributedTitle(NSAttributedString.attributedString(string: "Да", fontSize: 14, color: PaperColor.Gray800), for: .normal)
        submitButtonNode.setAttributedTitle(NSAttributedString.attributedString(string: "Да", fontSize: 14, color: PaperColor.Gray800.withAlphaComponent(0.5)), for: .disabled)
        submitButtonNode.isEnabled = state != .loading
        submitButtonNode.isHidden = state == .outOfDeliveryZone
    }
    
    override func setNeedsLayout() {
        separator.setNeedsLayout()
        addressTextNode.setNeedsLayout()
        activityIndicatorNode?.setNeedsLayout()
        submitButtonNode.setNeedsLayout()
        
        super.setNeedsLayout()
    }
    
    private func setupActivityIndicatorNode() {
        guard state == .loading else {
            activityIndicatorNode = nil
            return
        }
        
        activityIndicatorNode = ASDisplayNode(viewBlock: {
            let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicatorView.startAnimating()
            
            return activityIndicatorView
        })
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let addressSectionLayout = addressSectionLayoutThatFits(constrainedSize)
        addressSectionLayout.style.width = ASDimension(unit: .fraction, value: 0.67)
        
        separator.style.width = ASDimension(unit: .points, value: 1)
        separator.style.maxHeight = ASDimension(unit: .points, value: constrainedSize.min.height)
        
        let submitSectionLayout = submitSectionLayoutThatFits(constrainedSize)
        submitSectionLayout.style.width = ASDimension(unit: .fraction, value: 0.33)
        
        let layout = ASStackLayoutSpec.horizontal()
        layout.children = [addressSectionLayout, separator, submitSectionLayout]
        
        return layout
    }
    
    private func addressSectionLayoutThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let headerTextNodeLayout = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16), child: headerTextNode)
        let addressTextNodeLayout = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16), child: addressTextNode)
        
        addressTextNode.style.flexShrink = 1
        addressTextNode.style.flexGrow = 1
        
        let addressStack = ASStackLayoutSpec.vertical()
        addressStack.children = [headerTextNodeLayout, addressTextNodeLayout]
        
        return addressStack
    }
    
    private func submitSectionLayoutThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        guard let activityIndicatorNode = activityIndicatorNode else {
            return ASWrapperLayoutSpec(layoutElement: submitButtonNode)
        }
    
        activityIndicatorNode.style.maxHeight = ASDimension(unit: .points, value: constrainedSize.min.height)
        
        return ASWrapperLayoutSpec(layoutElement: activityIndicatorNode)
    }
}
