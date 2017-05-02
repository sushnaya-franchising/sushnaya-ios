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
    
    convenience init() {
        self.init(node: ASDisplayNode())
        
        self.node.backgroundColor = PaperColor.White
        self.node.automaticallyManagesSubnodes = true
        
        setupNodes()
    }

    private func setupNodes() {
        guard CLLocationManager.locationServicesEnabled() else {
            setupNodesIfLocationServicesDisabled()
            return
        }
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            setupNodesIfLocationServicesEnabled()
        default:
            setupNodesIfLocationServicesDisabled()
        }
    }        
    
    private func setupNodesIfLocationServicesEnabled() {
        self.navbarNode.delegate = self
        
        self.formNode = AddressFormNode()
        
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
                print("Error: \(error)")
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
        self.formNode = AddressFormNode()
        
        self.node.layoutSpecBlock = { [unowned self] _ in
            return ASOverlayLayoutSpec(child: self.formNode, overlay: self.navbarNode)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        geocoding?.apply()
    }
}

extension AddressViewController: AddressNavbarDelegate {
    func addressNavbarDidTapCloseButton(node: AddressNavbarNode) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addressNavbarDidTapMapButton(node: AddressNavbarNode) {
        self.pagerNode.scrollToPage(at: 0, animated: true)
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
}

extension AddressViewController: AddressMapDelegate {
    func addressMapWasDragged(_ node: AddressMapNode) {
        node.addressCalloutState = .loading
        geocoding?.apply()
    }
    
    func addressMapDidTapLocationButton(_ node: AddressMapNode) {
        CLLocationManager.promise().then {[unowned self] location -> () in
            self.mapNode.setCenter(coordinate: location.coordinate, animated: false)
            self.geocoding?.apply()
        }.catch { _ in
        }
    }
    
    func addressMap(_ node: AddressMapNode, gotTapAndHoldAt coordinate: CLLocationCoordinate2D) {
        node.setCenter(coordinate: coordinate, animated: true)
        node.addressCalloutState = .forceDeliveryPoint
    }
}
