//
//  AddressFormNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/28/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop

class AddressFormNode: ASCellNode {
    var locality: Locality
    
    fileprivate let headerTextNode = ASTextNode()
    
    fileprivate let localityTextNode = ASTextNode()
    fileprivate let localityImageNode: ASNetworkImageNode = {
        let imageNode = ASNetworkImageNode()
        imageNode.contentMode = .scaleAspectFit
        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(cornerRadius: 10)
        return imageNode
    }()
    
    fileprivate let streetHouseFormFieldNode = FormFieldNode(label: "Улица, дом", isRequired: true)
    fileprivate let apartmentNumberFormFieldNode = FormFieldNode(label: "Квартира/Офис", maxValueLength: 16)
    fileprivate let entranceFormFieldNode = FormFieldNode(label: "Подъезд", maxValueLength: 16)
    fileprivate let floorFormFieldNode = FormFieldNode(label: "Этаж", maxValueLength: 16)
    fileprivate let commentFormFieldNode = FormFieldNode(label: "Комментарий")
    
    var mapIsNotSupported = false {
        didSet {
            guard oldValue != mapIsNotSupported else {
                return
            }
            
            setupHeaderNode()
            headerTextNode.setNeedsLayout()
        }
    }
    
    init(locality: Locality) {
        self.locality = locality
        
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupHeaderNode()
        setupLocalityImageNode()
        setupLocalityTextNode()
        setupApartmentNumberFormFieldNode()
        setupFloorFormFieldNode()
        setupEntranceFormFieldNode()
    }
    
    private func setupHeaderNode() {
        headerTextNode.attributedText = NSAttributedString(string: "Адрес доставки", attributes: [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)
        ])
        
        headerTextNode.layer.opacity = mapIsNotSupported ? 1 : 0
    }
    
    private func setupLocalityTextNode() {
        localityTextNode.attributedText = NSAttributedString(string: locality.name, attributes:  [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
        ])
    }
    
    private func setupLocalityImageNode() {
        localityImageNode.defaultImage = UIImage(color: PaperColor.Gray300, size: CGSize(width: 32, height: 32))
        
        if let url = locality.coatOfArmsUrl {
            localityImageNode.url = URL(string: url)
        }
    }
    
    private func setupApartmentNumberFormFieldNode() {
        apartmentNumberFormFieldNode.keyboardType = .numberPad
    }
    
    private func setupFloorFormFieldNode() {
        floorFormFieldNode.keyboardType = .numberPad
    }
    
    private func setupEntranceFormFieldNode() {
        entranceFormFieldNode.keyboardType = .numberPad
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var rows = [ASLayoutElement]()
        
        rows.append(headerLayoutThatFits(constrainedSize))
        rows.append(localityLayoutThatFits(constrainedSize))
        rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 22, 0, 16), child: streetHouseFormFieldNode))
        rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 22, 0, 16), child: apartmentNumberFormFieldNode))
        rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 22, 0, 16), child: entranceFormFieldNode))
        rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 22, 0, 16), child: floorFormFieldNode))
        rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 22, 0, 16), child: commentFormFieldNode))
        
        let layout = ASStackLayoutSpec.vertical()
        layout.spacing = 16
        layout.children = rows
        
        return layout
    }
    
    private func headerLayoutThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let headerTextNodeLayout = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 36, left: 0, bottom: 0, right: 0), child: headerTextNode)
        headerTextNodeLayout.style.alignSelf = .center
        
        return headerTextNodeLayout
    }
    
    private func localityLayoutThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec.horizontal()
        stack.justifyContent = .start
        stack.alignItems = .center
        
        localityImageNode.style.preferredSize = CGSize(width: 32, height: 32)
        let imageNodeInsets = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 8)
        let imageNodeLayout = ASInsetLayoutSpec(insets: imageNodeInsets, child: localityImageNode)
        
        stack.children = [imageNodeLayout, localityTextNode]
        
        let rowInsets = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        return ASInsetLayoutSpec(insets: rowInsets, child: stack)
    }
}

fileprivate class FormFieldNode: ASDisplayNode {
    var isRequired: Bool
    var label: String
    var maxValueLength: Int
    
    var placeholderTextAttributes: [String: Any] = [NSForegroundColorAttributeName: PaperColor.Gray,
                                                    NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)] {
        didSet {
            editableTextNode.attributedPlaceholderText = NSAttributedString(string: label, attributes: placeholderTextAttributes)
        }
    }
    var typingAttributes: [String: Any] = [NSForegroundColorAttributeName: PaperColor.Gray800,
                                          NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)] {
        didSet {
            editableTextNode.typingAttributes = typingAttributes
        }
    }
    var maximumLinesToDisplay: UInt = 1 {
        didSet {
            editableTextNode.maximumLinesToDisplay = maximumLinesToDisplay
        }
    }
    var keyboardType: UIKeyboardType = .default {
        didSet {
            editableTextNode.keyboardType = keyboardType
        }
    }
    
    fileprivate let labelTextNode = ASTextNode()
    private var isLabelVisible = false
    private var labelCenterY:CGFloat?
    
    fileprivate let editableTextNode = ASEditableTextNode()
    fileprivate let iconImageNode: ASImageNode = {
        let imageNode = ASImageNode()
        imageNode.contentMode = .center
        return imageNode
    }()
    
    init(label: String, maxValueLength: Int = 128, isRequired:Bool = false) {
        self.label = label
        self.isRequired = isRequired
        self.maxValueLength = maxValueLength
        super.init()
        self.automaticallyManagesSubnodes = true
        setupNodes()
    }
    
    func setLabelVisible(visible: Bool, animated: Bool) {
        guard visible != self.isLabelVisible else {
            return
        }
        
        self.isLabelVisible = visible
        
        guard animated else {
            labelTextNode.layer.opacity = visible ? 1: 0
            labelTextNode.isHidden = !visible
            return
        }
        
        if let alphaAnimation = labelTextNode.pop_animation(forKey: "alpha") as? POPBasicAnimation {
            alphaAnimation.toValue = visible ? 1: 0
            alphaAnimation.completionBlock = { [unowned self] _ in
                if !visible {
                    self.labelTextNode.isHidden = !true
                }
            }
        
        } else {
            let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
            alphaAnimation?.fromValue = visible ? 0: 1
            alphaAnimation?.toValue = visible ? 1: 0
            alphaAnimation?.duration = 0.5
            alphaAnimation?.animationDidStartBlock = { [unowned self] _ in
                if visible {
                    self.labelTextNode.isHidden = false
                }
            }
            alphaAnimation?.completionBlock = { [unowned self] _ in
                if !visible {
                    self.labelTextNode.isHidden = !true
                }
            }
            
            labelTextNode.pop_add(alphaAnimation, forKey: "alpha")
        }
        
        guard let centerY = labelCenterY else {
            return
        }
        
        if let positionAnimation = labelTextNode.layer.pop_animation(forKey: "position") as? POPSpringAnimation {
            positionAnimation.toValue = visible ? centerY: centerY + 10
            
        } else {
            let positionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
            positionAnimation?.fromValue = visible ? centerY + 10: centerY
            positionAnimation?.toValue = visible ? centerY: centerY + 10
            
            labelTextNode.layer.pop_add(positionAnimation, forKey: "position")
        }
    }
    
    private func setupNodes() {
        setupIconImageNode()
        setupLabelTextNode()
        setupEditableTextNode()
    }
    
    private func setupIconImageNode() {
        iconImageNode.image = UIImage.fontAwesomeIcon(name: .pencil, textColor: isRequired ? PaperColor.Red: PaperColor.Gray, size: CGSize(width: 16, height: 16))
        iconImageNode.addTargetClosure { [unowned self] _ in
            self.editableTextNode.becomeFirstResponder()
        }
    }
    
    private func setupLabelTextNode() {
        labelTextNode.attributedText = NSAttributedString.attributedString(string: label, fontSize: 12, color: PaperColor.Gray, bold: false)
        labelTextNode.isHidden = true
    }
    
    private func setupEditableTextNode() {
        editableTextNode.attributedPlaceholderText = NSAttributedString(string: label, attributes: placeholderTextAttributes)
        editableTextNode.typingAttributes = typingAttributes
        editableTextNode.spellCheckingType = .no
        editableTextNode.returnKeyType = .done
        editableTextNode.autocorrectionType = .no
        editableTextNode.keyboardType = keyboardType
        editableTextNode.delegate = self
    }
    
    override func layout() {
        super.layout()
        labelCenterY = labelTextNode.view.center.y
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        labelTextNode.textContainerInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        iconImageNode.style.preferredSize = CGSize(width: 32, height: 32)
        editableTextNode.textContainerInset = UIEdgeInsets(top: 9, left: 8, bottom: 9, right: 0)
        editableTextNode.style.flexGrow = 1
        editableTextNode.style.flexShrink = 1
        
        let layout = ASStackLayoutSpec.vertical()
        let iconAndEditableText = ASStackLayoutSpec.horizontal()
        iconAndEditableText.justifyContent = .start
        iconAndEditableText.alignItems = .center
        
        iconAndEditableText.children = [iconImageNode, editableTextNode]
        layout.children = [labelTextNode, iconAndEditableText]
        
        return layout
    }
}

extension FormFieldNode: ASEditableTextNodeDelegate {
    func editableTextNode(_ editableTextNode: ASEditableTextNode, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let oldText = (editableTextNode.attributedText?.string ?? "") as NSString
        let newText = oldText.replacingCharacters(in: range, with: text)
        
        guard newText.characters.count <= maxValueLength else {
            return false
        }
        
        setLabelVisible(visible: !newText.isEmpty, animated: true)
        
        return true
    }
    
    func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
        self.setNeedsLayout()
    }
}

