import Foundation
import AsyncDisplayKit
import PromiseKit
import Alamofire

protocol EditAddressViewControllerDelegate: class {    
    func editAddressViewControllerDidTapBackButton(_ vc: EditAddressViewController)
}

class EditAddressViewController: ASViewController<EditAddressContentNode> {
    
    var addressToEdit: Address? {
        didSet {
            if let addressToEdit = addressToEdit {
                mapNode.setCenter(coordinate: addressToEdit.coordinate, animated: false)
                pagerNode.scrollToPage(at: 1, animated: false)
                node.navbarNode.selectedSegment = 1
                formNode.fill(address: addressToEdit)
            
            } else {
                mapNode.setCenter(coordinate: locality.coordinate, animated: false)
                pagerNode.scrollToPage(at: 0, animated: false)
                node.navbarNode.selectedSegment = 0
                formNode.clear()
            }
        }
    }
    
    var mapNode: EditAddressMapNode!
    var formNode: EditAddressFormNode!
    var addressSuggestionsWidget: AddressSuggestionsWidget!
    
    fileprivate var geocoding: Debouncer?
    fileprivate var tapRecognizer: UITapGestureRecognizer!
    
    fileprivate var isStreetAndHouseFormFieldFirstResponder: Bool = false
    fileprivate var dadataSuggestionsProvider: DadataSuggestionsProvider!
    
    fileprivate var adjustSuggestionsWidgetFrame: (() -> ())?
    
    fileprivate var addressOnMap: Address?
    
    weak var delegate: EditAddressViewControllerDelegate?
    
    var pagerNode: ASPagerNode {
        return node.pagerNode
    }
    
    var navbarNode: EditAddressNavbarNode {
        return node.navbarNode
    }
    
    var locality: LocalityEntity {
        return app.userSession.settings.menu!.locality
    }
    
    convenience init() {
        self.init(node: EditAddressContentNode())
        
        self.formNode = EditAddressFormNode()
        self.formNode.locality = locality
        self.formNode.delegate = self
        
        self.addressSuggestionsWidget = AddressSuggestionsWidget()
        self.addressSuggestionsWidget.delegate = self
        
        self.mapNode = EditAddressMapNode(locality: self.locality)
        self.mapNode.delegate = self
        self.mapNode.addressCallout.delegate = self
        
        self.pagerNode.setDataSource(self)
        self.pagerNode.setDelegate(self)
        
        self.navbarNode.delegate = self
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))
        tapRecognizer.delegate = self
        tapRecognizer.numberOfTapsRequired = 1
        
        self.node.automaticallyManagesSubnodes = true
        
        self.dadataSuggestionsProvider = DadataSuggestionsProvider(cityFiasId: locality.fiasId)
        self.addressSuggestionsWidget.provider = dadataSuggestionsProvider
        
        self.geocoding = debounce (delay: 0.1) { [unowned self] in
            YandexGeocoder.requestAddress(coordinate: self.mapNode.centerCoordinate).then { yandexAddress -> () in
                guard let yandexAddress = yandexAddress else {
                    self.mapNode.addressCallout.state = .addressIsUndefined
                    return
                }
                
                self.mapNode.setCenter(coordinate: yandexAddress.coordinate, animated: true)
                self.mapNode.addressCallout.state = .addressIsDefined(yandexAddress.displayName)
                // HERE
//                self.addressOnMap = yandexAddress.toAddress(locality: self.locality)
                
            }.catch { error in
                self.mapNode.addressCallout.state = .addressIsUndefined
            }
        }.onCancel {
            YandexGeocoder.cancelAllRequests()
        }

        // todo: subscribe to locality change event and update map and form locality
        // todo: reveal form if no internet connection available
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        geocoding?.apply()                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.addGestureRecognizer(tapRecognizer!)
        
        adjustMapLocationButtonVisibility()// todo: also update when application will resign active
        
        subscribeToKeyboardNotifications()                
    }
    
    private func adjustMapLocationButtonVisibility() {
        guard CLLocationManager.locationServicesEnabled() else {
            mapNode.isLocationButtonHidden = true
            return
        }
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            mapNode.isLocationButtonHidden = false
        default:
            mapNode.isLocationButtonHidden = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.view.removeGestureRecognizer(tapRecognizer!)
        
        unsubscribeFromKeyboardNotifications()
        
        EventBus.unregister(self)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.addressSuggestionsWidget.state = .closed
        self.view.endEditing(true)
    }
    
    fileprivate func submitAddress(_ address: Address) {
//        if let addressToEdit = addressToEdit {
//            addressToEdit.copyProperties(fromAddress: address)
//            
//            UpdateAddressEvent.fire(address: addressToEdit)
//            self.addressToEdit = nil
//        
//        } else {
//            CreateAddressEvent.fire(address: address)
//        }
    }
}

extension EditAddressViewController {
    var notificationCenter: NotificationCenter {
        return NotificationCenter.default
    }
    
    func subscribeToKeyboardNotifications() {
        notificationCenter.addObserver(self, selector: #selector(keyboardDidShow(notification:)),
                                       name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        guard isStreetAndHouseFormFieldFirstResponder else {
            return
        }
        
        addressSuggestionsWidget.state = .opened
        
        let keyboardHeight = getKeyboardHeight(notification: notification)
        let formFieldView = formNode.streetAndHouseFormFieldNode.view
        let suggestionsWidgetView = addressSuggestionsWidget.view

        adjustSuggestionsWidgetFrame = { [unowned self] _ in
            guard  let originY = formFieldView.superview?.convert(formFieldView.frame.origin, to: nil).y else {
                return
            }
            
            let origin = CGPoint(x: 0, y: originY + formFieldView.bounds.height - 78)
            let suggestionsWidgetHeight = self.view.bounds.height - keyboardHeight - origin.y
            let size = CGSize(width: self.view.bounds.width, height: suggestionsWidgetHeight)
            let frame = CGRect(origin: origin, size: size)
            
            guard frame != suggestionsWidgetView.frame else {
                return
            }
            
            let _ = self.addressSuggestionsWidget.layout(inFrame: frame).then { [unowned self] ()->() in
                if !self.view.subviews.contains(suggestionsWidgetView) {
                    self.view.addSubview(suggestionsWidgetView)
                }
            }
        }
        
        adjustSuggestionsWidgetFrame?()
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
    }
}

extension EditAddressViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: self.view)
        
        return !addressSuggestionsWidget.view.frame.contains(point)
    }
}

extension EditAddressViewController: EditAddressFormDelegate, AddressSuggestionsWidgetDelegate {
    func editAddressFormDidBeginEditing(_ node: EditAddressFormNode, streetAndHouseFormFieldNode formFieldNode: FormFieldNode) {
        isStreetAndHouseFormFieldFirstResponder = true
    }

    func editAddressFormDidFinishEditing(_ node: EditAddressFormNode, streetAndHouseFormFieldNode formFieldNode: FormFieldNode) {
        isStreetAndHouseFormFieldFirstResponder = false
        addressSuggestionsWidget.state = .closed
    }
    
    func editAddressFormDidUpdateValue(_ node: EditAddressFormNode, ofStreetAndHouseFormFieldNode formFieldNode: FormFieldNode) {
        let query = formFieldNode.value ?? ""
        dadataSuggestionsProvider.suggestHouseOnly = query.characters.contains(",")
        
        addressSuggestionsWidget.updateSuggestions(forQuery: query)
        addressSuggestionsWidget.state = .opened
    }
    
    func editAddressFormDidLayout(_ node: EditAddressFormNode, streetAndHouseFormFieldNode formFieldNode: FormFieldNode) {
        adjustSuggestionsWidgetFrame?()
    }
    
    func editAddressFormDidSubmit(_ node: EditAddressFormNode) {
        let streetAndHouse = node.streetAndHouseFormFieldNode.value!
        // todo: show loading indicator
        YandexGeocoder.requestAddress(query: "\(locality.name) \(streetAndHouse)").then { [unowned self] (yandexAddress) -> () in
            guard let yandexAddress = yandexAddress else {
                self.alert(title: "Неизвестный адрес", message: "Не удалось определить географические координаты адреса доставки. Попробуйте указать другой адрес.")
                return
            }
//HERE
//            let addressInForm = yandexAddress.toAddress(locality: self.locality)
//            addressInForm.apartment = node.apartmentFormFieldNode.value
//            addressInForm.entrance = node.entranceFormFieldNode.value
//            addressInForm.floor = node.floorFormFieldNode.value
//            addressInForm.comment = node.commentFormFieldNode.value
//            
//            self.submitAddress(addressInForm)
            
        }.catch { error in
            self.alert(title: "Возникла ошибка", message: error.localizedDescription)
        }
    }
    
    func addressSuggestionsWidget(_ widget: AddressSuggestionsWidget, didSelectSuggestion suggestion: String) {
        formNode.streetAndHouseFormFieldNode.setValue(suggestion, notifyDelegate: false)
        addressSuggestionsWidget.state = .closed
        
        if !suggestion.characters.contains(",") {
            formNode.streetAndHouseFormFieldNode.setValue("\(suggestion), ")
        }
    }
}

extension EditAddressViewController: EditAddressNavbarDelegate {
    func editAddressNavbarDidTapBackButton(node: EditAddressNavbarNode) {
        self.view.endEditing(true)
        delegate?.editAddressViewControllerDidTapBackButton(self)
    }
    
    func editAddressNavbarDidTapMapButton(node: EditAddressNavbarNode) {
        self.pagerNode.scrollToPage(at: 0, animated: true)
        self.view.endEditing(true)
    }
    
    func editAddressNavbarDidTapFormButton(node: EditAddressNavbarNode) {
        self.pagerNode.scrollToPage(at: 1, animated: true)
    }
}

extension EditAddressViewController: ASPagerDataSource, ASPagerDelegate {
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return 2
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        return index == 0 ? self.mapNode: self.formNode
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.navbarNode.selectedSegment = pagerNode.currentPageIndex
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

extension EditAddressViewController: EditAddressMapDelegate, EditAddressMapCalloutDelegate { // todo: mapnode delegate submit button handler!
    func editAddressMapWasDragged(_ node: EditAddressMapNode) {        
        node.addressCallout.state = .loading
        geocoding?.apply()
    }
    
    func editAddressMapDidTapLocationButton(_ node: EditAddressMapNode) {
        geocoding?.cancel()
        
        CLLocationManager.promise().then {[unowned self] location -> () in
            self.mapNode.setCenter(coordinate: location.coordinate, animated: false)
            self.geocoding?.apply()
        }.catch { _ in
        }
    }
    
    func editAddressMap(_ node: EditAddressMapNode, gotTapAndHoldAt coordinate: CLLocationCoordinate2D) {
        geocoding?.cancel()
        
        node.setCenter(coordinate: coordinate, animated: true)
        node.addressCallout.state = .forceDeliveryPoint
    }
    
    func editAddressMapCalloutDidSubmit(_ node: EditAddressMapCalloutNode) {
        guard let addressOnMap = self.addressOnMap else {
            // todo: pass as geopoint to order view controller or ignore if it's address edition in settings
            return
        }
        
        // todo: user networking for address persistance
        submitAddress(addressOnMap)
    }        
}
