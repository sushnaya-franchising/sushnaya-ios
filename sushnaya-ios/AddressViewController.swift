//
// Created by Igor Kurylenko on 4/25/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import PromiseKit
import Alamofire

protocol AddressViewControllerDelegate: class {
    func addressViewController(_ vc: AddressViewController, didSubmitAddress address: Address)
}

class AddressViewController: ASViewController<ASDisplayNode> {
    
    fileprivate let navbarNode = AddressNavbarNode()
    fileprivate var pagerNode: ASPagerNode!
    fileprivate var mapNode: AddressMapNode!
    fileprivate var formNode: AddressFormNode!
    fileprivate var addressSuggestionsWidget: SuggestionsWidget!
    
    fileprivate var geocoding: Debouncer?
    fileprivate var tapRecognizer: UITapGestureRecognizer!
    
    fileprivate var isStreetAndHouseFormFieldFirstResponder: Bool = false
    fileprivate var dadataSuggestionsProvider: DadataSuggestionsProvider!
    
    fileprivate var adjustSuggestionsWidgetFrame: (() -> ())?
    
    fileprivate var addressOnMap: Address!
    
    weak var delegate: AddressViewControllerDelegate?
    
    var locality: Locality {
        return app.userSession.locality!
    }
    
    convenience init() {
        self.init(node: ASDisplayNode())
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))
        tapRecognizer.delegate = self
        tapRecognizer.numberOfTapsRequired = 1
        
        self.node.backgroundColor = PaperColor.White
        self.node.automaticallyManagesSubnodes = true
        
        setupNodes()
        
        // todo: subscribe to locality change event and update map and form locality
        // todo: reveal form if no internet connection available
    }

    private func setupNodes() {
        self.navbarNode.delegate = self
        
        self.formNode = AddressFormNode(locality: locality)
        self.formNode.delegate = self
        
        self.addressSuggestionsWidget = SuggestionsWidget()
        dadataSuggestionsProvider = DadataSuggestionsProvider(cityFiasId: locality.fiasId)
        self.addressSuggestionsWidget.provider = dadataSuggestionsProvider
        self.addressSuggestionsWidget.delegate = self
        
        self.mapNode = AddressMapNode(locality: locality)
        self.addressOnMap = Address(locality: locality, coordinate: locality.location.coordinate)
        self.mapNode?.delegate = self
        self.mapNode?.addressCallout.delegate = self
        
        self.geocoding = debounce (delay: 0.1) { [unowned self] in
            YandexGeocoder.requestAddress(coordinate: self.mapNode!.centerCoordinate).then { address -> () in
                guard let address = address else {
                    self.mapNode.addressCallout.state = .addressIsUndefined
                    return
                }
                
                self.mapNode!.setCenter(coordinate: address.coordinate, animated: true)
                self.mapNode.addressCallout.state = .addressIsDefined(address.displayName)
                self.addressOnMap = address.toAddress(locality: self.locality)
                
            }.catch { error in
                self.mapNode.addressCallout.state = .addressIsUndefined
            }
        }.onCancel {
            YandexGeocoder.cancelAllRequests()
        }
        
        self.pagerNode = ASPagerNode()
        self.pagerNode.allowsAutomaticInsetsAdjustment = true
        self.pagerNode.setDataSource(self)
        self.pagerNode.setDelegate(self)
        
        self.node.layoutSpecBlock = { [unowned self] _ in
            return ASOverlayLayoutSpec(child: self.pagerNode, overlay: self.navbarNode)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        geocoding?.apply()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.addGestureRecognizer(tapRecognizer!)
        
        updateMapLocationButtonVisibility()// todo: also update when application will resign active
        
        subscribeToKeyboardNotifications()
    }
    
    private func updateMapLocationButtonVisibility() {
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
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.addressSuggestionsWidget.state = .closed
        self.view.endEditing(true)
    }
}

extension AddressViewController {
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
            
            let origin = CGPoint(x: 0, y: originY + formFieldView.bounds.height)
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

extension AddressViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: self.view)
        
        return !addressSuggestionsWidget.view.frame.contains(point)
    }
}

extension AddressViewController: AddressFormDelegate, SuggestionsWidgetDelegate {
    func addressFormDidBeginEditing(_ node: AddressFormNode, streetAndHouseFormFieldNode formFieldNode: FormFieldNode) {
        isStreetAndHouseFormFieldFirstResponder = true
    }

    func addressFormDidFinishEditing(_ node: AddressFormNode, streetAndHouseFormFieldNode formFieldNode: FormFieldNode) {
        isStreetAndHouseFormFieldFirstResponder = false
        addressSuggestionsWidget.state = .closed
    }
    
    func addressFormDidUpdateValue(_ node: AddressFormNode, ofStreetAndHouseFormFieldNode formFieldNode: FormFieldNode) {
        let query = formFieldNode.value ?? ""
        dadataSuggestionsProvider.suggestHouseOnly = query.characters.contains(",")
        
        addressSuggestionsWidget.updateSuggestions(forQuery: query)
        addressSuggestionsWidget.state = .opened
    }
    
    func addressFormDidLayout(_ node: AddressFormNode, streetAndHouseFormFieldNode formFieldNode: FormFieldNode) {
        adjustSuggestionsWidgetFrame?()
    }
    
    func addressFormDidSubmit(_ node: AddressFormNode) {
        let streetAndHouse = node.streetAndHouseFormFieldNode.value!
        // todo: show loading indicator
        YandexGeocoder.requestAddress(query: "\(locality.name) \(streetAndHouse)").then { [unowned self] (yandexAddress) -> () in
            guard let coordinate = yandexAddress?.coordinate else {
                self.alert(title: "Неизвестный адрес", message: "Не удалось определить географические координаты адреса доставки. Попробуйте указать другой адрес.")
                return
            }
            
            let address = Address(locality: self.locality,
                                  coordinate: coordinate,
                                  streetAndHouse: streetAndHouse,
                                  apartment: node.apartmentFormFieldNode.value,
                                  entrance: node.entranceFormFieldNode.value,
                                  floor: node.floorFormFieldNode.value,
                                  comment: node.commentFormFieldNode.value)
                        
            self.delegate?.addressViewController(self, didSubmitAddress: address)
                                    
        }.catch { error in
            self.alert(title: "Возникла ошибка", message: error.localizedDescription)
        }
    }
    
    func suggestionsWidget(_ widget: SuggestionsWidget, didSelectSuggestion suggestion: String) {
        formNode.streetAndHouseFormFieldNode.setValue(suggestion, notifyDelegate: false)
        addressSuggestionsWidget.state = .closed
        
        if !suggestion.characters.contains(",") {
            formNode.streetAndHouseFormFieldNode.setValue("\(suggestion), ")
        }
    }
}

extension AddressViewController: AddressNavbarDelegate {
    func addressNavbarDidTapBackButton(node: AddressNavbarNode) {
        self.dismiss(animated: true, completion: nil)
        self.view.endEditing(true)
    }
    
    func addressNavbarDidTapMapButton(node: AddressNavbarNode) {
        self.pagerNode.scrollToPage(at: 0, animated: true)
        self.view.endEditing(true)
    }
    
    func addressNavbarDidTapFormButton(node: AddressNavbarNode) {
        self.pagerNode.scrollToPage(at: 1, animated: true)
    }
}

extension AddressViewController: ASPagerDataSource, ASPagerDelegate {
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

extension AddressViewController: AddressMapDelegate, AddressMapCalloutDelegate { // todo: mapnode delegate submit button handler!
    func addressMapWasDragged(_ node: AddressMapNode) {
        self.addressOnMap = Address(locality: locality, coordinate: node.centerCoordinate)
        node.addressCallout.state = .loading
        geocoding?.apply()
    }
    
    func addressMapDidTapLocationButton(_ node: AddressMapNode) {
        geocoding?.cancel()
        
        CLLocationManager.promise().then {[unowned self] location -> () in
            self.mapNode.setCenter(coordinate: location.coordinate, animated: false)
            self.geocoding?.apply()
        }.catch { _ in
        }
    }
    
    func addressMap(_ node: AddressMapNode, gotTapAndHoldAt coordinate: CLLocationCoordinate2D) {
        geocoding?.cancel()
        
        self.addressOnMap = Address(locality: locality, coordinate: node.centerCoordinate)
        
        node.setCenter(coordinate: coordinate, animated: true)
        node.addressCallout.state = .forceDeliveryPoint
    }
    
    func addressMapCalloutDidSubmit(_ node: AddressMapCalloutNode) {
        self.delegate?.addressViewController(self, didSubmitAddress: addressOnMap!)
    }
}
