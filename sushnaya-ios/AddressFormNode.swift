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
    
    fileprivate let scrollNode = ASScrollNode()
    fileprivate var keyboardHeight: CGFloat?
    
    fileprivate let localityTextNode = ASTextNode()
    fileprivate let localityImageNode: ASNetworkImageNode = {
        let imageNode = ASNetworkImageNode()
        imageNode.contentMode = .scaleAspectFit
        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(cornerRadius: 10)
        return imageNode
    }()
    
    fileprivate let streetHouseFormFieldNode = FormFieldNode(label: "Улица, дом", isRequired: true)
    fileprivate let suggestionsTableNode = ASTableNode()
    fileprivate let apartmentNumberFormFieldNode = FormFieldNode(label: "Квартира/Офис")
    fileprivate let entranceFormFieldNode = FormFieldNode(label: "Подъезд")
    fileprivate let floorFormFieldNode = FormFieldNode(label: "Этаж", maxValueLength: 16)
    fileprivate let commentFormFieldNode = FormFieldNode(label: "Комментарий")
    
    fileprivate let submitButton = ASButtonNode()        
    
    fileprivate let navbarBackgroundNode = ASDisplayNode()
    fileprivate let navbarTitleTextNode = ASTextNode()
    
    var navbarTitle: String? {
        didSet {
            setupNavbarTitleNode()
        }
    }
    
    init(locality: Locality) {
        self.locality = locality
        
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        setupNodes()
        
        subscribeToKeyboardNotifications()
    }
    
    deinit {
        unsubscribeFromKeyboardNotifications()
    }
    
    private func setupNodes() {        
        setupScrollNode()
        setupNavbarTitleNode()
        setupNavbarBackgroundNode()
        setupLocalityImageNode()
        setupLocalityTextNode()
        setupSuggestionsTableNode()
        setupFloorFormFieldNode()
        setupCommentFormFieldNode()
        setupSubmitButton()
    }
    
    private func setupNavbarTitleNode() {
        guard let title = navbarTitle else {
            return
        }
        
        navbarTitleTextNode.attributedText = NSAttributedString(string: title, attributes: [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)
        ])                
    }
    
    private func setupNavbarBackgroundNode() {
        navbarBackgroundNode.backgroundColor = PaperColor.White.withAlphaComponent(0.93)
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
    
    private func setupSuggestionsTableNode() {
        suggestionsTableNode.delegate = self
        suggestionsTableNode.dataSource = self
        suggestionsTableNode.isHidden = true
    }
    
    private func setupFloorFormFieldNode() {
        floorFormFieldNode.keyboardType = .numberPad
    }
    
    private func setupCommentFormFieldNode() {
        commentFormFieldNode.returnKeyType = .done
    }
    
    private func setupSubmitButton() {
        let title = NSAttributedString(string: "Готово", attributes: [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
        ])
        submitButton.setAttributedTitle(title, for: .normal)
        submitButton.backgroundColor = PaperColor.Gray300
    }
    
    private func setupScrollNode() {
        scrollNode.automaticallyManagesSubnodes = true
        scrollNode.automaticallyManagesContentSize = true
        
        scrollNode.layoutSpecBlock = { [unowned self] node, constrainedSize in
            self.submitButton.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 44)
            
            var rows = [ASLayoutElement]()
            rows.append(self.localityLayoutThatFits(constrainedSize))
            rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 22, 0, 16), child: self.streetHouseFormFieldNode))
            
            if self.suggestionsTableNode.isVisible {
                self.suggestionsTableNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 44*4)
                rows.append(self.suggestionsTableNode)
            }
            
            rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 22, 0, 16), child: self.apartmentNumberFormFieldNode))
            rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 22, 0, 16), child: self.entranceFormFieldNode))
            rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 22, 0, 16), child: self.floorFormFieldNode))
            rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 22, 0, 16), child: self.commentFormFieldNode))
            
            let spacer = ASLayoutSpec()
            spacer.style.flexGrow = 1
            rows.append(spacer)
            
            rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(16, 16, 16, 16), child: self.submitButton))
            
            let layout = ASStackLayoutSpec.vertical()
            layout.spacing = 16
            layout.children = rows
            
            return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(84, 0, 0, 0), child: layout)
        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        scrollNode.view.delegate = self
        
        suggestionsTableNode.view.separatorStyle = .none
        
        submitButton.cornerRadius = 11
        submitButton.clipsToBounds = true
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        
        DispatchQueue.main.async { [unowned self] _ in
            self.adjustScrollNodeOffset()
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let backgroundRow = ASStackLayoutSpec.horizontal()
        let titleTextLayout = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: ASInsetLayoutSpec(insets: UIEdgeInsetsMake(20, 0, 0, 0), child: navbarTitleTextNode))
        navbarBackgroundNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 72)
        let backgroundLayout = ASOverlayLayoutSpec(child: navbarBackgroundNode, overlay: titleTextLayout)
        backgroundLayout.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 72)
        backgroundRow.children = [backgroundLayout]
        
        return ASOverlayLayoutSpec(child: scrollNode, overlay: backgroundRow)
    }
    
    private func localityLayoutThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASStackLayoutSpec.horizontal()
        layout.justifyContent = .start
        layout.alignItems = .center
        
        localityImageNode.style.preferredSize = CGSize(width: 32, height: 32)
        let imageNodeInsets = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 8)
        let imageNodeLayout = ASInsetLayoutSpec(insets: imageNodeInsets, child: localityImageNode)
        
        layout.children = [imageNodeLayout, localityTextNode]
        
        
        return layout
    }
}

extension AddressFormNode: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

extension AddressFormNode: ASTableDelegate, ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let suggestion = "address \(indexPath.row)"
        
        return {
            SuggestionCellNode(suggestion: suggestion)
        }
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        // todo: implement
        print("OK")
    }
}

extension AddressFormNode {
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
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.keyboardHeight!, right: 0)
        
        scrollNode.view.contentInset = contentInsets
        scrollNode.view.scrollIndicatorInsets = contentInsets
        
        adjustScrollNodeOffset()
    }
    
    func adjustScrollNodeOffset() {
        if let keyboardHeight = self.keyboardHeight,
            let view = self.view.currentFirstResponder() as? UIView,
            let originY = view.superview?.convert(view.frame.origin, to: nil).y {
            let destOriginY:CGFloat = 98 // todo: improve ui design concept
            let maxOffsetY = scrollNode.view.contentSize.height - (self.view.bounds.height - keyboardHeight)
            let delta = (destOriginY + view.bounds.height) - (self.view.bounds.height - keyboardHeight)
            
            if delta > 0 {
                let offsetY = min(scrollNode.view.contentOffset.y + (originY - destOriginY) + delta, maxOffsetY)
                scrollNode.view.contentOffset = CGPoint(x: 0, y: offsetY)
                
            } else {
                let offsetY = min(scrollNode.view.contentOffset.y + (originY - destOriginY), maxOffsetY)
                scrollNode.view.contentOffset = CGPoint(x:0, y: offsetY)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        scrollNode.view.contentInset = .zero
        scrollNode.view.scrollIndicatorInsets = .zero
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
    }
}

fileprivate class FormFieldNode: ASDisplayNode {
    var value: String = "" {
        didSet {
            guard oldValue != value else {
                return
            }
            
            setupIconImageNode()
        }
    }
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
        switch (isRequired, value.characters.count) {
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
        editableTextNode.returnKeyType = returnKeyType
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
    func editableTextNodeDidBeginEditing(_ editableTextNode: ASEditableTextNode) {
        DispatchQueue.main.async {
            editableTextNode.selectedRange = NSMakeRange(editableTextNode.attributedText?.length ?? 0, 0)
        }
    }
    
    func editableTextNode(_ editableTextNode: ASEditableTextNode, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let oldText = (editableTextNode.attributedText?.string ?? "") as NSString
        let newText = oldText.replacingCharacters(in: range, with: text)
        
        guard newText.characters.count <= maxValueLength else {
            return false
        }
        
        setLabelVisible(visible: !newText.isEmpty, animated: true)
        
        value = newText
        
        return true
    }
    
    func editableTextNodeDidUpdateText(_ editableTextNode: ASEditableTextNode) {
        self.setNeedsLayout()
    }
}
