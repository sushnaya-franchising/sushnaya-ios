//
// Created by Igor Kurylenko on 4/25/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class AddressViewController: ASViewController<ASDisplayNode> {        
    
    fileprivate let navbarNode = AddressNavbarNode()
    fileprivate var pagerNode: ASPagerNode!
    fileprivate var mapNode: AddressMapNode!
    fileprivate var formNode: AddressFormNode!
    
    fileprivate var geocoding: Debouncer?
    fileprivate var tapRecognizer: UITapGestureRecognizer!
    
    convenience init() {
        self.init(node: ASDisplayNode())
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))
        tapRecognizer.numberOfTapsRequired = 1
        
        self.node.backgroundColor = PaperColor.White
        self.node.automaticallyManagesSubnodes = true
        
        setupNodes()                
    }

    private func setupNodes() {
//        guard CLLocationManager.locationServicesEnabled() else {
            setupNodesIfLocationServicesDisabled()
//            return
//        }

//        switch CLLocationManager.authorizationStatus() {
//        case .authorizedAlways, .authorizedWhenInUse:
//            setupNodesIfLocationServicesEnabled()
//        default:
//            setupNodesIfLocationServicesDisabled()
//        }
    }
    
    private func setupNodesIfLocationServicesEnabled() {
        self.navbarNode.delegate = self
        
        self.formNode = AddressFormNode(locality: app.userSession.locality!)
        
        self.mapNode = AddressMapNode()
        self.mapNode?.delegate = self
        
        self.geocoding = debounce (delay: 0.1) { [unowned self] in
            YandexGeocoder.requestAddress(coordinate: self.mapNode!.centerCoordinate).then{ address -> () in
                guard let address = address else {
                    self.mapNode.addressCalloutState = .addressIsUndefined
                    return
                }
                
                self.mapNode!.setCenter(coordinate: address.coordinate, animated: true)
                self.mapNode.addressCalloutState = .addressIsDefined(address.displayName)
                
            }.catch { error in
                self.mapNode.addressCalloutState = .addressIsUndefined
            }
        }
        
        self.pagerNode = ASPagerNode()
        self.pagerNode.allowsAutomaticInsetsAdjustment = true
        self.pagerNode.setDataSource(self)
        self.pagerNode.setDelegate(self)
        
        self.node.layoutSpecBlock = { [unowned self] _ in
            return ASOverlayLayoutSpec(child: self.pagerNode, overlay: self.navbarNode)
        }
    }
    
    private func setupNodesIfLocationServicesDisabled() {
        self.navbarNode.delegate = self
        self.navbarNode.isSegmentedControlHidden = true
        
        self.formNode = AddressFormNode(locality: app.userSession.locality!)
        self.formNode.navbarTitle = "Адрес доставки"
        
        self.node.layoutSpecBlock = { [unowned self] (node, constrainedSize) in
            return ASOverlayLayoutSpec(child: self.formNode, overlay: self.navbarNode)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        geocoding?.apply()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

extension AddressViewController: AddressNavbarDelegate {
    func addressNavbarDidTapCloseButton(node: AddressNavbarNode) {
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

extension AddressViewController: AddressMapDelegate {
    func addressMapWasDragged(_ node: AddressMapNode) {
        node.addressCalloutState = .loading
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
        
        node.setCenter(coordinate: coordinate, animated: true)
        node.addressCalloutState = .forceDeliveryPoint
    }
}
