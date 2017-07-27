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
    
    fileprivate var labelNode: ASDisplayNode?
    fileprivate var labelView: UILabel?
    
    fileprivate let highlighter = ASDisplayNode()
    fileprivate var mapImageNode = ASImageNode()
    fileprivate let localityImageNode: ASNetworkImageNode = {
        let imageNode = ASNetworkImageNode()
        imageNode.contentMode = .scaleAspectFit
        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(cornerRadius: 10)
        return imageNode
    }()
    
    override var isSelected: Bool {
        didSet {
            adjustHighlighterNodeBgColor()
            adjustHighlighterNodeOpacity()
            adjustLabelTextNodeOpacity()
            adjustLocalityImageNodeOpacity()
        }
    }
    
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
        setupLocalityImageNode()
    }
    
    private func setupHighlighterNode() {
        adjustHighlighterNodeBgColor()
    }
    
    private func adjustHighlighterNodeBgColor() {
        highlighter.backgroundColor = isSelected ? PaperColor.White : PaperColor.Gray200
    }
    
    private func setupLabelNode() {
        guard let addressDisplayName = address.displayName else { return }
        
        self.labelNode = ASDisplayNode(viewBlock: { [unowned self] _ in
            let labelView = UILabel()
            self.labelView = labelView
            labelView.textAlignment = .center
            labelView.lineBreakMode = .byWordWrapping
            labelView.numberOfLines = 0
            
            let stringAttributes:[String: Any] = [
                NSForegroundColorAttributeName: PaperColor.Gray800,
                NSBackgroundColorAttributeName: PaperColor.White,
                NSFontAttributeName: self.getLabelFont(addressDisplayName)
            ]
            
            labelView.attributedText = NSMutableAttributedString(string: "\(addressDisplayName) ",
                attributes: stringAttributes)
            
            return labelView
        })
    }
    
    private func getLabelFont(_ labelText: String) -> UIFont {
        // todo: measure font to determine a size
        return labelText.characters.count <= 40 ? UIFont.boldSystemFont(ofSize: 14):
                labelText.characters.count <= 50 ? UIFont.boldSystemFont(ofSize: 13):
                labelText.characters.count <= 60 ? UIFont.boldSystemFont(ofSize: 12):
                UIFont.boldSystemFont(ofSize: 11)
    }
    
    private func setupLocalityImageNode() {
        localityImageNode.defaultImage = UIImage(color: PaperColor.Gray300, size: CGSize(width: 32, height: 32))
        
        if let url = address.locality.coatOfArmsUrl {
            localityImageNode.url = URL(string: url)
        }
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.cornerRadius = 11
        self.clipsToBounds = true                
        
        highlighterDidLoad()
        mapImageNodeDidLoad()
        labelTextNodeDidLoad()
        localityImageNodeDidLoad()
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
        labelNode?.layer.opacity = isSelected ? 1 : 0.5
    }
    
    private func adjustLocalityImageNodeOpacity() {
        localityImageNode.layer.opacity = isSelected ? 1: 0.5
    }
    
    private func mapImageNodeDidLoad() {
        mapImageNode.view.layer.cornerRadius = 10
        mapImageNode.view.clipsToBounds = true
    }
    
    private func localityImageNodeDidLoad() {
        adjustLocalityImageNodeOpacity()
    }
        
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let contentSize = CGSize(width: constrainedSize.max.width - 4, height: constrainedSize.max.height - 4)
        
        mapImageNode.style.preferredSize = contentSize
        createStaticMap(imageSize: contentSize)
        let mapImageLayout = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: mapImageNode)
        
        highlighter.style.preferredSize = contentSize
        let highlighterLayout = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: highlighter)
        
        localityImageNode.style.preferredSize = CGSize(width: 32, height: 32)
        let localityImageLayout = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child:
            ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 40, 0), child: localityImageNode))
        
        guard let labelNode = labelNode else {
            return ASOverlayLayoutSpec(child: mapImageLayout, overlay:
                ASOverlayLayoutSpec(child: highlighterLayout, overlay: localityImageLayout))
        }
        
        let spacer = ASLayoutSpec()
        spacer.style.height = ASDimension(unit: .fraction, value: 1 / Constants.GoldenRatio)
        labelNode.style.maxHeight = ASDimension(unit: .fraction, value: 1 - 1 / Constants.GoldenRatio)
        let labelLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 8, 8, 8), child: labelNode)
        let labelStackLayout = ASStackLayoutSpec.vertical()
        labelStackLayout.children = [spacer, labelLayout]
        
        return ASOverlayLayoutSpec(child: mapImageLayout, overlay:
            ASOverlayLayoutSpec(child: highlighterLayout, overlay:
                ASOverlayLayoutSpec(child: localityImageLayout, overlay: labelStackLayout)))
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
