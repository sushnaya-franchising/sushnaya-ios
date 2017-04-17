//
//  CategorySideTableCellNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/1/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class FilterCellNode: ASCellNode {

    let imageCornerRadius = Constants.FilterCellLayout.ImageCornerRadius
    let cellBackgroundColor = Constants.FilterCellLayout.BackgroundColor
    let cellSelectedBackground = Constants.FilterCellLayout.SelectedBackgroundColor
    let cellInsets = Constants.FilterCellLayout.CellInsets
    
    let imageNode: ASImageNode = {// todo: make it ASNetworkingNode
        let imageNode = ASImageNode()
        imageNode.contentMode = .scaleAspectFit
//        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(
//            cornerRadius: Constants.LocalityCellLayout.ImageCornerRadius)
        return imageNode
    }()

    let titleLabel = ASTextNode()    
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? cellSelectedBackground: cellBackgroundColor
        }
    }
    
    init(filter: CellData) {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.selectionStyle = .none
        self.backgroundColor = cellBackgroundColor
        
        setupNodes(filter)
    }
    
    private func setupNodes(_ filter: CellData) {
        setupImageNode(filter)
        setupTitleLabel(filter)
    }
    
    private func setupImageNode(_ filter: CellData) {
        //imageNode.defaultImage = UIImage(color: PaperColor.Gray300, size: Constants.CellLayout.CoatOfArmsImageSize)
        
        if let image = filter.image {
            let size = image.size
            if size.width < Constants.FilterCellLayout.ImageSize.width ||
                size.height < Constants.FilterCellLayout.ImageSize.height {
                imageNode.backgroundColor = PaperColor.Gray300
                imageNode.contentMode = .center
            }
            
            imageNode.image = image
        
        } else if let url = filter.imageUrl {
        //    imageNode.url = URL(string: url)
            imageNode.image = UIImage(named: url)
        }
    }

    override func didLoad() {
        super.didLoad()
        
        imageNode.layer.cornerRadius = imageCornerRadius // todo: use optimized corner radius, update corner radius in ASNetworkImageNodeDelegate
        imageNode.clipsToBounds = true
    }
    
    private func setupTitleLabel(_ filter: CellData) {
        titleLabel.attributedText = NSAttributedString(string: filter.title, attributes: Constants.FilterCellLayout.TitleStringAttributes)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec { 
        let stack = ASStackLayoutSpec.vertical()
        stack.alignItems = .center
        stack.justifyContent = .start
        
        imageNode.style.preferredSize = Constants.FilterCellLayout.ImageSize
        
        titleLabel.style.maxWidth = ASDimension(unit: .points, value: Constants.FilterCellLayout.ImageSize.width)
        
        stack.children = [
                imageNode,
                ASInsetLayoutSpec(insets: Constants.FilterCellLayout.TitleLabelInsets, child: titleLabel)
        ]
        
        return ASInsetLayoutSpec(insets: cellInsets, child: stack)
    }
}

