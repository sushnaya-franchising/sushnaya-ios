//
//  AddressCellNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 7/1/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import SwiftEventBus

class AddressCellNode: ASCellNode {
    static let LabelStringAttributes:[String: Any] = [
        NSForegroundColorAttributeName: PaperColor.Gray800,
        NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
    ]
    
    static let InsetBottom: CGFloat = 32
    
    static let MapMarkerIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .mapMarker),
                                                        attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 28),
                                                                     NSForegroundColorAttributeName: PaperColor.Gray800])
    
    static let RemoveIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .trashO),
                                                        attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 24),
                                                                     NSForegroundColorAttributeName: PaperColor.Gray800])
    
    static let EditIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .pencilSquareO),
                                                     attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 24),
                                                                  NSForegroundColorAttributeName: PaperColor.Gray800])    
    
    var address: Address
    
    fileprivate let mapImageBuilder = YMKMapImageBuilder()
    fileprivate var labelNode: ASTextNode?
    let mapMarkerTextNode = ASTextNode()
    let editButtonNode = ASButtonNode()
    let removeButtonNode = ASButtonNode()
    fileprivate let mapImageNode: ASImageNode = {
        let imageNode = ASImageNode()
        imageNode.contentMode = .scaleAspectFit
        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(cornerRadius: 11 * UIScreen.main.scale)
        
        return imageNode
    }()
    
    init(address: Address) {
        self.address = address
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        self.mapImageBuilder?.delegate = self                
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupLabelNode()
        setupMapMarkerNode()
        setupEditButtonNode()
        setupRemoveButtonNode()
    }
    
    private func setupLabelNode() {
        labelNode = ASTextNode()
        labelNode?.attributedText = NSMutableAttributedString(string: address.displayName,
            attributes: AddressCellNode.LabelStringAttributes)
    }
    
    private func setupMapMarkerNode() {
        mapMarkerTextNode.attributedText = AddressCellNode.MapMarkerIconString
    }
    
    private func setupEditButtonNode() {
        editButtonNode.setAttributedTitle(AddressCellNode.EditIconString, for: .normal)
        editButtonNode.setBackgroundImage(UIImage.init(color: PaperColor.White.withAlphaComponent(0.5)), for: .normal)
        editButtonNode.isHidden = true
        editButtonNode.setTargetClosure { [unowned self] _ in
            ShowEditAddressViewControllerEvent.fire(address: self.address)
        }
    }
    
    private func setupRemoveButtonNode() {
        removeButtonNode.setAttributedTitle(AddressCellNode.RemoveIconString, for: .normal)
        removeButtonNode.setBackgroundImage(UIImage.init(color: PaperColor.White.withAlphaComponent(0.5)), for: .normal)
        removeButtonNode.isHidden = true
        // HERE
//        removeButtonNode.setTargetClosure { [unowned self] _ in
//            RemoveAddressEvent.fire(addressId: self.address.serverId!)
//        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let layout = ASStackLayoutSpec.vertical()
        var resultLayoutChildren = [ASLayoutElement]()
     
        mapMarkerTextNode.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        let mapMarkerLayout = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: mapMarkerTextNode)
        
        let mapImageNodeSize = AddressCellNode.calculateMapImageSize()
        self.mapImageNode.style.preferredSize = mapImageNodeSize
        createStaticMap(imageSize: mapImageNodeSize)
        
        let editModeButtonsLayout = ASStackLayoutSpec.horizontal()
        
        editButtonNode.style.preferredSize = CGSize(width: mapImageNodeSize.width/2, height: mapImageNodeSize.height)
        removeButtonNode.style.preferredSize = CGSize(width: mapImageNodeSize.width/2, height: mapImageNodeSize.height)
        
        editModeButtonsLayout.children = [editButtonNode, removeButtonNode]
        
        let mapLayout = ASOverlayLayoutSpec(child: ASOverlayLayoutSpec(child: mapImageNode, overlay: mapMarkerLayout), overlay: editModeButtonsLayout)
        
        resultLayoutChildren.append(mapLayout)
        
        if let labelNode = labelNode {
            let labelLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(8, 0, 0, 0), child: labelNode)
            resultLayoutChildren.append(labelLayout)
        }
        
        layout.children = resultLayoutChildren

        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, AddressCellNode.InsetBottom, 0), child: layout)
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

extension AddressCellNode {
    static func calculateMapImageSize() -> CGSize {
        let screenBounds = UIScreen.main.bounds
        let width = screenBounds.width - 32
        let height = width / (Constants.GoldenRatio * Constants.GoldenRatio)
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
}
