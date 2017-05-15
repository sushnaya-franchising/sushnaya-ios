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
import Alamofire

protocol AddressFormDelegate: class {
    func addressFormDidBeginEditing(_ node: AddressFormNode, streetAndHouseFormFieldNode formFieldNode: FormFieldNode)
    
    func addressFormDidFinishEditing(_ node: AddressFormNode, streetAndHouseFormFieldNode formFieldNode: FormFieldNode)
    
    func addressFormDidLayout(_ node: AddressFormNode, streetAndHouseFormFieldNode formFieldNode: FormFieldNode)
    
    func addressFormDidUpdateValue(_ node: AddressFormNode, ofStreetAndHouseFormFieldNode formFieldNode: FormFieldNode)
    
    func addressFormDidSubmit(_ node: AddressFormNode)
}

class AddressFormNode: ASCellNode {
    var locality: Locality
    
    weak var delegate: AddressFormDelegate?
    
    fileprivate let scrollNode = ASScrollNode()
    fileprivate var keyboardHeight: CGFloat = 0
    
    fileprivate let localityTextNode = ASTextNode()
    fileprivate let localityImageNode: ASNetworkImageNode = {
        let imageNode = ASNetworkImageNode()
        imageNode.contentMode = .scaleAspectFit
        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(cornerRadius: 10)
        return imageNode
    }()
    
    let streetAndHouseFormFieldNode = FormFieldNode(label: "Улица, дом", isRequired: true)
    let apartmentFormFieldNode = FormFieldNode(label: "Квартира/Офис")
    let entranceFormFieldNode = FormFieldNode(label: "Подъезд")
    let floorFormFieldNode = FormFieldNode(label: "Этаж", maxValueLength: 16)
    let commentFormFieldNode = FormFieldNode(label: "Комментарий")
    
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
        setupStreetAndHouseFormFieldNode()
        setupApartmentNumberFormFieldNode()
        setupEntranceFormFieldNode()
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
    
    private func setupStreetAndHouseFormFieldNode() {
        streetAndHouseFormFieldNode.didBeginEditing = { [unowned self] in
            self.delegate?.addressFormDidBeginEditing(self, streetAndHouseFormFieldNode: self.streetAndHouseFormFieldNode)
        }
        streetAndHouseFormFieldNode.didUpdateValue = { [unowned self] in
            self.delegate?.addressFormDidUpdateValue(self, ofStreetAndHouseFormFieldNode: self.streetAndHouseFormFieldNode)
        }
        streetAndHouseFormFieldNode.didFinishEditing = { [unowned self] in
            self.delegate?.addressFormDidFinishEditing(self, streetAndHouseFormFieldNode: self.streetAndHouseFormFieldNode)
        }
        streetAndHouseFormFieldNode.onReturn = { [unowned self] in
            self.apartmentFormFieldNode.becomeFirstResponder()
        }
        streetAndHouseFormFieldNode.didLayout = { [unowned self] in
            self.delegate?.addressFormDidLayout(self, streetAndHouseFormFieldNode: self.streetAndHouseFormFieldNode)
        }
    }        
    
    private func setupApartmentNumberFormFieldNode() {
        apartmentFormFieldNode.onReturn = { [unowned self] in
            self.entranceFormFieldNode.becomeFirstResponder()
        }
    }
    
    private func setupEntranceFormFieldNode() {
        entranceFormFieldNode.onReturn = { [unowned self] in
            self.floorFormFieldNode.becomeFirstResponder()
        }
    }
    
    private func setupFloorFormFieldNode() {
        floorFormFieldNode.keyboardType = .numberPad
        floorFormFieldNode.onReturn = { [unowned self] in
            self.commentFormFieldNode.becomeFirstResponder()
        }
    }
    
    private func setupCommentFormFieldNode() {
        commentFormFieldNode.returnKeyType = .done
        commentFormFieldNode.onReturn = { [unowned self] in
            self.commentFormFieldNode.resignFirstResponder()
        }
    }
    
    private func setupSubmitButton() {
        let title = NSAttributedString(string: "Готово", attributes: [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
        ])
        submitButton.setAttributedTitle(title, for: .normal)
        submitButton.backgroundColor = PaperColor.Gray300
        submitButton.setTargetClosure { [unowned self] _ in
            self.view.endEditing(true)
            
            guard self.streetAndHouseFormFieldNode.isValid else {
                self.onStreetAndHouseConstraintViolation()
                return
            }
            
            // request yandex geocoder to detect delivery coordinate
            // show button loader while request is being processed
            
            self.delegate?.addressFormDidSubmit(self)
        }
    }
    
    private func setupScrollNode() {
        scrollNode.automaticallyManagesSubnodes = true
        scrollNode.automaticallyManagesContentSize = true
        
        scrollNode.layoutSpecBlock = { [unowned self] node, constrainedSize in
            var rows = [ASLayoutElement]()
            rows.append(self.localityLayoutThatFits(constrainedSize))
            rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 22, 0, 16), child: self.streetAndHouseFormFieldNode))
            
            rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 22, 0, 16), child: self.apartmentFormFieldNode))
            rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 22, 0, 16), child: self.entranceFormFieldNode))
            rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 22, 0, 16), child: self.floorFormFieldNode))
            rows.append(ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 22, 0, 16), child: self.commentFormFieldNode))
            
            let spacer = ASLayoutSpec()
            spacer.style.flexGrow = 1
            spacer.style.flexShrink = 1
            rows.append(spacer)
            
            self.submitButton.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 44)
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
        navbarBackgroundNode.style.preferredSize = CGSize(width: constrainedSize.max.width, height: 72)
        backgroundRow.children = [navbarBackgroundNode]
        
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

extension AddressFormNode {
    func onStreetAndHouseConstraintViolation() {
        DispatchQueue.main.async { [unowned self] _ in
            self.scrollFormFieldToVisible(self.streetAndHouseFormFieldNode)
            self.playShakeAnimation(self.streetAndHouseFormFieldNode)
        }
    }

    fileprivate func scrollFormFieldToVisible(_ formFieldNode: FormFieldNode) {
        let origin  = formFieldNode.frame.origin
        let size = formFieldNode.frame.size
        let rect = CGRect(origin: CGPoint(x: origin.x, y: origin.y - navbarBackgroundNode.bounds.height), size: size)
        
        scrollNode.view.scrollRectToVisible(rect, animated: true)
    }
    
    fileprivate func playShakeAnimation(_ formFieldNode: FormFieldNode) {
        guard (formFieldNode.pop_animation(forKey: "shake") == nil) else {
            return
        }

        let shake = POPSpringAnimation(propertyNamed: kPOPLayerPositionX)
        shake?.springBounciness = 20
        shake?.velocity = 1500
        
        formFieldNode.pop_add(shake, forKey: "shake")
    }
}

extension AddressFormNode: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == scrollNode.view {
            self.view.endEditing(true)
        }
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
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.keyboardHeight, right: 0)
        
        scrollNode.view.contentInset = contentInsets
        scrollNode.view.scrollIndicatorInsets = contentInsets
        
        adjustScrollNodeOffset()
    }
    
    func adjustScrollNodeOffset() {
        if  let view = getFirstResponderAsFormFieldView(),
            let originY = view.superview?.convert(view.frame.origin, to: nil).y {
            let destOriginY:CGFloat = self.navbarBackgroundNode.bounds.height
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
    
    fileprivate func getFirstResponderAsFormFieldView() -> UIView? {
        guard let view = self.view.currentFirstResponder() as? UIView else {
            return nil
        }
        
        return view.superview?.superview
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

