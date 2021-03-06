import Foundation
import AsyncDisplayKit
import pop
import Alamofire

protocol EditAddressFormDelegate: class {
    func editAddressFormDidBeginEditing(_ node: EditAddressFormNode, streetAndHouseFormFieldNode formFieldNode: FormFieldNode)
    
    func editAddressFormDidFinishEditing(_ node: EditAddressFormNode, streetAndHouseFormFieldNode formFieldNode: FormFieldNode)
    
    func editAddressFormDidLayout(_ node: EditAddressFormNode, streetAndHouseFormFieldNode formFieldNode: FormFieldNode)
    
    func editAddressFormDidUpdateValue(_ node: EditAddressFormNode, ofStreetAndHouseFormFieldNode formFieldNode: FormFieldNode)
    
    func editAddressFormDidSubmit(_ node: EditAddressFormNode)
}

class EditAddressFormNode: ASCellNode {
    var locality: LocalityEntity? {
        didSet {
            adjustLocalityTextNode()
            adjustLocalityImageNode()
        }
    }
    
    weak var delegate: EditAddressFormDelegate?
    
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
    
    override init() {
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
    
    private func setupNavbarBackgroundNode() {
        navbarBackgroundNode.backgroundColor = PaperColor.White.withAlphaComponent(0.93)
    }
    
    private func setupLocalityTextNode() {
        adjustLocalityTextNode()
    }
    
    private func adjustLocalityTextNode() {
        guard let locality = locality else { return }
        
        localityTextNode.attributedText = NSAttributedString(string: locality.name, attributes:  [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
        ])
    }
    
    private func setupLocalityImageNode() {
        localityImageNode.placeholderEnabled = true
        localityImageNode.placeholderColor = PaperColor.Gray100
        localityImageNode.placeholderFadeDuration = 0.1
        
        adjustLocalityImageNode()
    }
    
    private func adjustLocalityImageNode() {
        guard let locality = locality else { return }
        
        print(FoodServiceImages.getCoatOfArmsImageUrl(coordinate: locality.coordinate))
        
        localityImageNode.url = FoodServiceImages.getCoatOfArmsImageUrl(coordinate: locality.coordinate)
    }
    
    private func setupStreetAndHouseFormFieldNode() {
        streetAndHouseFormFieldNode.didBeginEditing = { [unowned self] in
            self.delegate?.editAddressFormDidBeginEditing(self, streetAndHouseFormFieldNode: self.streetAndHouseFormFieldNode)
        }
        streetAndHouseFormFieldNode.didUpdateValue = { [unowned self] in
            self.delegate?.editAddressFormDidUpdateValue(self, ofStreetAndHouseFormFieldNode: self.streetAndHouseFormFieldNode)
        }
        streetAndHouseFormFieldNode.didFinishEditing = { [unowned self] in
            self.delegate?.editAddressFormDidFinishEditing(self, streetAndHouseFormFieldNode: self.streetAndHouseFormFieldNode)
        }
        streetAndHouseFormFieldNode.onReturn = { [unowned self] in
            self.apartmentFormFieldNode.becomeFirstResponder()
        }
        streetAndHouseFormFieldNode.didLayout = { [unowned self] in
            self.delegate?.editAddressFormDidLayout(self, streetAndHouseFormFieldNode: self.streetAndHouseFormFieldNode)
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
            
            self.delegate?.editAddressFormDidSubmit(self)
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
            
            return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(88, 0, 0, 0), child: layout)
        }
    }
    
    override func didLoad() {
        super.didLoad()
        scrollNode.view.showsVerticalScrollIndicator = false
        scrollNode.view.showsHorizontalScrollIndicator = false
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
    
    public func fill(address: Address) {
        streetAndHouseFormFieldNode.setValue(address.streetAndHouse, notifyDelegate: false)
        apartmentFormFieldNode.setValue(address.apartment, notifyDelegate: false)
        entranceFormFieldNode.setValue(address.entrance, notifyDelegate: false)
        floorFormFieldNode.setValue(address.floor, notifyDelegate: false)
        commentFormFieldNode.setValue(address.comment, notifyDelegate: false)
    }
    
    public func clear() {
        streetAndHouseFormFieldNode.setValue(nil, notifyDelegate: false)
        apartmentFormFieldNode.setValue(nil, notifyDelegate: false)
        entranceFormFieldNode.setValue(nil, notifyDelegate: false)
        floorFormFieldNode.setValue(nil, notifyDelegate: false)
        commentFormFieldNode.setValue(nil, notifyDelegate: false)
    }
}

extension EditAddressFormNode {
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

extension EditAddressFormNode: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == scrollNode.view {
            self.view.endEditing(true)
        }
    }
}

extension EditAddressFormNode {
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
            let destOriginY:CGFloat = self.navbarBackgroundNode.bounds.height + 78
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

