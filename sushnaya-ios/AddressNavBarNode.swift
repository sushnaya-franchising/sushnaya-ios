//
//  AddressNavBarNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/28/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol AddressNavbarDelegate: class {
    func addressNavbarDidTapCloseButton(node: AddressNavbarNode)
    
    func addressNavbarDidTapMapButton(node: AddressNavbarNode)
    
    func addressNavbarDidTapFormButton(node: AddressNavbarNode)
}

class AddressNavbarNode: ASDisplayNode {
    fileprivate let chevronUpIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .chevronUp), attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 16), NSForegroundColorAttributeName: PaperColor.Gray800])
    fileprivate let mapIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .mapO), attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 16), NSForegroundColorAttributeName: PaperColor.Gray800])
    fileprivate let keyboardIconString = NSAttributedString(string: String.fontAwesomeIcon(name: .keyboardO), attributes: [NSFontAttributeName: UIFont.fontAwesome(ofSize: 17), NSForegroundColorAttributeName: PaperColor.Gray800])
    
    fileprivate let segmentedControl = SegmentedControlNode()
    fileprivate let closeButton = ASButtonNode()
    
    var isSegmentedControlHidden: Bool {
        get {
            return segmentedControl.isHidden
        }
        
        set {
            segmentedControl.isHidden = newValue
        }
    }
    
    var selectedSegment: Int {
        set {
            segmentedControl.selectedSegment = newValue
        }
        
        get{
            return segmentedControl.selectedSegment
        }
    }
    
    weak var delegate: AddressNavbarDelegate?
    
    override init() {
        super.init()
            
        self.automaticallyManagesSubnodes = true        
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupCloseButtonNode()
        setupSegmentedControlNode()
    }
    
    private func setupCloseButtonNode() {
        closeButton.setAttributedTitle(chevronUpIconString, for: .normal)
        closeButton.addTargetClosure { [unowned self] _ in
            self.delegate?.addressNavbarDidTapCloseButton(node: self)
        }
    }
    
    private func setupSegmentedControlNode() {
        segmentedControl.backgroundColor = PaperColor.Gray200.withAlphaComponent(0.95)
        segmentedControl.delegate = self
        
        let mapButton = ASButtonNode()
        mapButton.setAttributedTitle(mapIconString, for: .normal)
        segmentedControl.addButton(mapButton)
        
        let keyboardButton = ASButtonNode()
        keyboardButton.setAttributedTitle(keyboardIconString, for: .normal)
        segmentedControl.addButton(keyboardButton)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subnode in subnodes {
            if subnode.hitTest(convert(point, to: subnode), with: event) != nil {
                return true
            }
        }
        return false
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.segmentedControl.cornerRadius = 11
        self.segmentedControl.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        closeButton.hitTestSlop = UIEdgeInsets(top: -22, left: -22, bottom: -22, right: -22)
        closeButton.style.preferredSize = CGSize(width: 44, height: 44)
        let closeButtonLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(24, 16, 0, 0), child: closeButton)
        
        let closeButtonRow = ASStackLayoutSpec.horizontal()
        closeButtonRow.alignItems = .start
        closeButtonRow.children = [closeButtonLayout]
        
        segmentedControl.style.maxHeight = ASDimension(unit: .points, value: 44)
        let segmentedControlLayout = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(24, 0, 0, 0), child: segmentedControl)
        
        let segmentedControlRow = ASStackLayoutSpec.horizontal()
        segmentedControlRow.alignItems = .start
        segmentedControlRow.justifyContent = .center
        segmentedControlRow.children = [segmentedControlLayout]
        
        return ASOverlayLayoutSpec(child: closeButtonRow, overlay: segmentedControlRow)
    }
}

extension AddressNavbarNode: SegmentedControlDelegate {
    func segmentedControl(segmentedControl: SegmentedControlNode, didSelectSegment segment: Int) {
        switch  segment {
        case 0:
            self.delegate?.addressNavbarDidTapMapButton(node: self)
        case 1:
            self.delegate?.addressNavbarDidTapFormButton(node: self)
        default:
            break
        }
    }
}
