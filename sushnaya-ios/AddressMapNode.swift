//
//  AddressMapNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/28/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol AddressMapDelegate: class {
    func addressMapDidTapLocationButton(_ node: AddressMapNode)
    
    func addressMapWasDragged(_ node: AddressMapNode)
}

class AddressMapNode: ASCellNode {
    
    fileprivate let locationArrowIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .locationArrow), attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 16), NSForegroundColorAttributeName: PaperColor.Gray800])
    fileprivate let mapMarkerIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .mapMarker), attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 44), NSForegroundColorAttributeName: PaperColor.Red800])
    
    fileprivate var mapNode: ASDisplayNode!
    fileprivate let locationButton = ASButtonNode()
    fileprivate let mapMarker = ASTextNode()
    
    fileprivate var mapView: YMKMapView!
    
    var centerCoordinate: CLLocationCoordinate2D {
        let coordinate = mapView.centerCoordinate
        return CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    weak var delegate: AddressMapDelegate?        
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true            
        
        self.locationButton.setAttributedTitle(locationArrowIconString, for: .normal)
        self.locationButton.addTargetClosure {[unowned self] _ in
            self.delegate?.addressMapDidTapLocationButton(self)
        }
        
        self.mapMarker.attributedText = mapMarkerIconString
        
        self.mapNode = ASDisplayNode(viewBlock: { [unowned self] _ in
            let mapView = YMKMapView()
            self.mapView = mapView
            mapView.showsUserLocation = false
            mapView.showTraffic = false
            mapView.delegate = self
            
            CLLocationManager.promise().then { location -> () in
                mapView.setCenter(location.coordinate, atZoomLevel: 16, animated: false)
            }.catch { _ in
            }
            
            return mapView
        })
    }
    
    func setCenter(coordinate: CLLocationCoordinate2D, animated: Bool) {
        mapView.setCenter(YMKMapCoordinateMake(coordinate.latitude, coordinate.longitude), animated: animated)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        locationButton.hitTestSlop = UIEdgeInsets(top: -22, left: -22, bottom: -22, right: -22)
        locationButton.style.preferredSize = CGSize(width: 44, height: 44)
        let locationButtonLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(24, 0, 0, 16), child: locationButton)
        
        let locationButtonRow = ASStackLayoutSpec.horizontal()
        locationButtonRow.alignItems = .start
        locationButtonRow.justifyContent = .end
        locationButtonRow.children = [locationButtonLayout]
        
        mapMarker.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)        
        let mapMarkerLayout = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: mapMarker)
        
        mapNode.style.preferredSize = constrainedSize.max
        
        let mapWithLocationButton = ASOverlayLayoutSpec(child: mapNode, overlay: locationButtonRow)
        
        return ASOverlayLayoutSpec(child: mapWithLocationButton, overlay: mapMarkerLayout)
    }
}

extension AddressMapNode: YMKMapViewDelegate {
    func mapView(_ mapView: YMKMapView!, locationManagerDidReceiveError error: Error!) {
        print(error)
    }
    
    func mapViewWasDragged(_ mapView: YMKMapView!) {        
        self.delegate?.addressMapWasDragged(self)
    }
}
