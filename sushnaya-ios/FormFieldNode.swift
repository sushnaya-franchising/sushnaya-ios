//
//  FormFieldNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 5/9/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import pop
import AsyncDisplayKit


class FormFieldNode: ASDisplayNode {
    private(set) var value: String? {
        didSet {
            guard oldValue != value else {
                return
            }
            
            setupIconImageNode()
            setLabelVisible(visible: !isValueEmpty, animated: true)
            
            if self.editableTextNode.attributedText?.string != value {
                self.editableTextNode.setTextWhileKeepingAttributes(text: value ?? "")
            }
        }
    }
    
    var isRequired: Bool
    var label: String
    var maxValueLength: Int
    
    var onReturn: (()->())?
    var didBeginEditing: (()->())?
    var didUpdateValue: (()->())?
    var didFinishEditing: (()->())?
    var didLayout: (()->())?
    
    var isValid: Bool {
        guard isRequired else {
            return true
        }
        
        return !isValueEmpty
    }
    
    var isValueEmpty: Bool {
        return value?.isEmpty ?? true
    }
    
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
    
    var returnKeyType: UIReturnKeyType = .next {
        didSet {
            editableTextNode.returnKeyType = returnKeyType
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
    
    var iconImageColor: UIColor {
        switch (isRequired, value?.characters.count ?? 0) {
        case (true, 0):
            return PaperColor.Red
        case (true, 1):
            return PaperColor.Green200
        case (true, 2):
            return PaperColor.Green300
        case (true, 3):
            return PaperColor.Green400
        case (true, 4):
            return PaperColor.Green500
        case (true, _):
            return PaperColor.Green600
        default:
            return PaperColor.Gray
        }
    }
    
    init(label: String, maxValueLength: Int = 128, isRequired:Bool = false) {
        self.label = label
        self.isRequired = isRequired
        self.maxValueLength = maxValueLength
        super.init()
        self.automaticallyManagesSubnodes = true
        setupNodes()
    }
    
    func setValue(_ value: String?, notifyDelegate: Bool = true) {
        guard value != self.value else {
            return
        }
        
        self.value = value
        
        if notifyDelegate {
            didUpdateValue?()
        }
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return editableTextNode.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return editableTextNode.resignFirstResponder()
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
        iconImageNode.image = UIImage.fontAwesomeIcon(name: .pencil, textColor: iconImageColor, size: CGSize(width: 16, height: 16))
        iconImageNode.setTargetClosure { [unowned self] _ in
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
        editableTextNode.returnKeyType = returnKeyType
        editableTextNode.autocorrectionType = .no
        editableTextNode.keyboardType = keyboardType
        editableTextNode.delegate = self
    }
    
    override func layout() {
        super.layout()
        labelCenterY = labelTextNode.view.center.y
        didLayout?()
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
    func editableTextNodeDidBeginEditing(_ editableTextNode: ASEditableTextNode) {
        DispatchQueue.main.async { [unowned self] _ in
            editableTextNode.selectedRange = NSMakeRange(editableTextNode.attributedText?.length ?? 0, 0)
            self.didBeginEditing?()
        }
    }
    
    func editableTextNode(_ editableTextNode: ASEditableTextNode, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text.rangeOfCharacter(from: .newlines) == nil else {
            onReturn?()
            return false
        }
        
        let oldText = (editableTextNode.attributedText?.string ?? "") as NSString
        let newText = oldText.replacingCharacters(in: range, with: text)
        
        return newText.characters.count <= maxValueLength
    }
    
    func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
        DispatchQueue.main.async { [unowned self] _ in
            self.setValue(editableTextNode.attributedText?.string)
            self.setNeedsLayout()
        }
    }
    
    func editableTextNodeDidFinishEditing(_ editableTextNode: ASEditableTextNode) {
        DispatchQueue.main.async { [unowned self] _ in
            self.didFinishEditing?()
        }
    }
}
