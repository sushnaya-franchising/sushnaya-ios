import Foundation
import AsyncDisplayKit

protocol EditAddressMapDelegate: class {
    func editAddressMapDidTapLocationButton(_ node: EditAddressMapNode)
    
    func editAddressMapWasDragged(_ node: EditAddressMapNode)
    
    func editAddressMap(_ node: EditAddressMapNode, gotTapAndHoldAt coordinate: CLLocationCoordinate2D)
}

class EditAddressMapNode: ASCellNode {
    fileprivate let zoomLevel:UInt = 16
    fileprivate let locationArrowIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .locationArrow),
                                                                 attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 16), NSForegroundColorAttributeName: PaperColor.Gray800])
    static let MapMarkerIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .mapPin),
                                                        attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 32), NSForegroundColorAttributeName: PaperColor.Gray800])
    
    fileprivate var mapNode: ASDisplayNode!
    fileprivate let locationButton = ASButtonNode()
    fileprivate let mapMarker = ASTextNode()
    let addressCallout = EditAddressMapCalloutNode()
    fileprivate var mapView: YMKMapView!
    
    var isLocationButtonHidden: Bool {
        get {
            return locationButton.isHidden
        }
        
        set {
            locationButton.isHidden = newValue
        }
    }
    
    var centerCoordinate: CLLocationCoordinate2D {
        let coordinate = mapView.centerCoordinate
        return CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    weak var delegate: EditAddressMapDelegate?
    
    init(locality: LocalityEntity) {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        setupLocationButtonNode()
        
        self.addressCallout.backgroundColor = PaperColor.Gray200.withAlphaComponent(0.93)
        
        self.mapMarker.attributedText = EditAddressMapNode.MapMarkerIconString
        
        self.mapNode = ASDisplayNode(viewBlock: { [unowned self] _ in
            let mapView = YMKMapView()
            self.mapView = mapView
            mapView.showsUserLocation = false
            mapView.showTraffic = false
            mapView.delegate = self
            
            CLLocationManager.promise().then { location -> () in
                mapView.setCenter(location.coordinate, atZoomLevel: self.zoomLevel, animated: false)
                
            }.catch { _ in
                mapView.setCenter(locality.coordinate, atZoomLevel: self.zoomLevel, animated: false)
            }
            
            return mapView
        })
    }
    
    private func setupLocationButtonNode() {
        self.locationButton.setAttributedTitle(locationArrowIconString, for: .normal)
        
        self.locationButton.setTargetClosure {[unowned self] _ in
            self.delegate?.editAddressMapDidTapLocationButton(self)
        }
    }
    
    func setCenter(coordinate: CLLocationCoordinate2D, animated: Bool) {
        mapView.setCenter(YMKMapCoordinateMake(coordinate.latitude, coordinate.longitude), animated: animated)
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.addressCallout.cornerRadius = 11
        self.addressCallout.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        locationButton.hitTestSlop = UIEdgeInsets(top: -22, left: -22, bottom: -22, right: -22)
        locationButton.style.preferredSize = CGSize(width: 44, height: 44)
        let locationButtonLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(24, 0, 0, 16), child: locationButton)
        
        mapMarker.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        let mapMarkerLayout = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: mapMarker)
        
        addressCallout.style.maxHeight = ASDimension(unit: .points, value: 100)
        addressCallout.style.minHeight = ASDimension(unit: .points, value: 88)
        addressCallout.style.flexShrink = 1
        let addressCalloutLayout = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16), child: addressCallout)
        
        mapNode.style.preferredSize = constrainedSize.max
        
        let locationButtonRow = ASStackLayoutSpec.horizontal()
        locationButtonRow.alignItems = .start
        locationButtonRow.justifyContent = .end
        locationButtonRow.children = [locationButtonLayout]
        
        let spacer = ASLayoutSpec()
        spacer.style.flexGrow = 1.0
        
        let controls = ASStackLayoutSpec.vertical()
        controls.children = [locationButtonRow, spacer, addressCalloutLayout]
        
        let mapWithControls = ASOverlayLayoutSpec(child: mapNode, overlay: controls)
        
        return ASOverlayLayoutSpec(child: mapWithControls, overlay: mapMarkerLayout)
    }
}

extension EditAddressMapNode: YMKMapViewDelegate {
    func mapView(_ mapView: YMKMapView!, gotTapAndHoldAt coordinate: YMKMapCoordinate) {
        self.delegate?.editAddressMap(self, gotTapAndHoldAt: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
    
    func mapViewWasDragged(_ mapView: YMKMapView!) {
        self.delegate?.editAddressMapWasDragged(self)
    }
}
