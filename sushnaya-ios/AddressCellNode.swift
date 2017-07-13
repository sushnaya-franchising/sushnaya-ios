//
//  AddressCellNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 7/1/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class AddressCellNode: ASCellNode {
    var address: Address
    fileprivate let mapImageBuilder = YMKMapImageBuilder()
    
    fileprivate let labelTextNode = ASTextNode()
    fileprivate let highlighter = ASDisplayNode()
    fileprivate var mapImageNode = ASImageNode()
    fileprivate let mapMarkerNode = ASTextNode()
    
    fileprivate let mapMarkerIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .mapMarker), attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 27), NSForegroundColorAttributeName: PaperColor.Gray800])
    
    override var isSelected: Bool {
        didSet {
            adjustHighlighterNodeBgColor()
            adjustHighlighterNodeOpacity()
            adjustLabelTextNodeOpacity()
            adjustMapMarkerNodeOpacity()
        }
    }
    
    fileprivate static let LabelStringAttributes:[String: Any] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        return [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14),
            NSParagraphStyleAttributeName : paragraphStyle
        ]
    }()
    
    init(address: Address) {
        self.address = address
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = PaperColor.Gray200
        
        self.mapImageBuilder?.delegate = self
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupHighlighterNode()
        setupLabelNode()
        setupMapMarkerNode()
    }
    
    private func setupHighlighterNode() {
        adjustHighlighterNodeBgColor()
    }
    
    private func adjustHighlighterNodeBgColor() {
        highlighter.backgroundColor = isSelected ? PaperColor.White : PaperColor.Gray200
    }
    
    private func setupLabelNode() {
        guard let addressDisplayName = address.displayName else { return }
        
        labelTextNode.attributedText = NSAttributedString(string: addressDisplayName,
                                                          attributes: AddressCellNode.LabelStringAttributes)
    }
    
    private func setupMapMarkerNode() {
        mapMarkerNode.attributedText = mapMarkerIconString
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.cornerRadius = 11
        self.clipsToBounds = true                
        
        highlighterDidLoad()
        mapImageNodeDidLoad()
        labelTextNodeDidLoad()
        mapMarkerNodeDidLoad()
    }

    private func highlighterDidLoad() {
        highlighter.cornerRadius = 10
        highlighter.clipsToBounds = true
        adjustHighlighterNodeOpacity()
    }
    
    private func adjustHighlighterNodeOpacity() {
        highlighter.layer.opacity = isSelected ? 0.5 : 0.7
    }
    
    private func labelTextNodeDidLoad() {
        adjustLabelTextNodeOpacity()
    }
    
    private func adjustLabelTextNodeOpacity() {
        labelTextNode.layer.opacity = isSelected ? 1 : 0.5
    }
    
    private func adjustMapMarkerNodeOpacity() {
        mapMarkerNode.layer.opacity = isSelected ? 1 : 0.5
    }
    
    private func mapImageNodeDidLoad() {
        mapImageNode.view.layer.cornerRadius = 10
        mapImageNode.view.clipsToBounds = true
    }
    
    private func mapMarkerNodeDidLoad() {
        adjustMapMarkerNodeOpacity()
    }
        
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let labelLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 8, 8, 8), child: labelTextNode)
        let labelStackLayout = ASStackLayoutSpec.vertical()
        let spacer = ASLayoutSpec()
        spacer.style.height = ASDimension(unit: .fraction, value: 1 / Constants.GoldenRatio)
        labelStackLayout.children = [spacer, labelLayout]
        
        let contentSize = CGSize(width: constrainedSize.max.width - 4, height: constrainedSize.max.height - 4)
        
        mapImageNode.style.preferredSize = contentSize
        createStaticMap(imageSize: contentSize)
        let mapImageLayout = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: mapImageNode)
        
        highlighter.style.preferredSize = contentSize
        let highlighterLayout = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: highlighter)
        
        mapMarkerNode.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        let mapMarkerLayout = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: mapMarkerNode)
        
        return ASOverlayLayoutSpec(child: mapImageLayout, overlay:
            ASOverlayLayoutSpec(child: highlighterLayout, overlay:
                ASOverlayLayoutSpec(child: mapMarkerLayout, overlay: labelStackLayout)))
    }
    
    private func createStaticMap(imageSize: CGSize) {
        DispatchQueue.main.async { [unowned self] _ in
            self.mapImageBuilder?.cancel()
        
            self.mapImageBuilder?.centerCoordinate = self.address.coordinate
            self.mapImageBuilder?.zoomLevel = 16
            self.mapImageBuilder?.imageSize = imageSize
            self.mapImageBuilder?.build()
        }
    }
    
    fileprivate func mapRenderingDoneWithImage(image: UIImage?) {
        self.mapImageNode.image = image
    }
}

extension AddressCellNode: YMKMapImageBuilderDelegate {
    func mapImageBuilder(_ builder: YMKMapImageBuilder!, builtImage image: UIImage!) {
        mapRenderingDoneWithImage(image: image)
    }
    
    func mapImageBuilderFailed(toLoadCompleteImage builder: YMKMapImageBuilder!, partialImage image: UIImage!) {
        mapRenderingDoneWithImage(image: image)
    }
    
    func mapImageBuilderWasCancelled(_ builder: YMKMapImageBuilder!) {
        mapRenderingDoneWithImage(image: self.mapImageNode.image)
    }
}
