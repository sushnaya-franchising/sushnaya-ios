//
//  CategorySideTableCellNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/1/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class CategorySmallCellNode: ASCellNode {

    let imageCornerRadius = Constants.CategorySmallCellLayout.ImageCornerRadius
    let cellBackgroundColor = Constants.CategorySmallCellLayout.BackgroundColor
    let cellSelectedBackground = Constants.CategorySmallCellLayout.SelectedBackgroundColor
    
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
    
    init(category: MenuCategory) {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.selectionStyle = .none
        self.backgroundColor = cellBackgroundColor
        
        setupNodes(category)
    }
    
    private func setupNodes(_ category: MenuCategory) {
        setupImageNode(category)
        setupTitleLabel(category)
    }
    
    private func setupImageNode(_ category: MenuCategory) {
        //imageNode.defaultImage = UIImage(color: PaperColor.Gray300, size: Constants.CellLayout.CoatOfArmsImageSize)
        
        if let url = category.photoUrl {
        //    imageNode.url = URL(string: url)
            imageNode.image = UIImage(named: url)
        }
    }

    override func didLoad() {
        super.didLoad()
        
        imageNode.layer.cornerRadius = imageCornerRadius // todo: use optimized corner radius, update corner radius in ASNetworkImageNodeDelegate
        imageNode.clipsToBounds = true
    }
    
    private func setupTitleLabel(_ category: MenuCategory) {
        titleLabel.attributedText = NSAttributedString(string: category.title, attributes: Constants.CategorySmallCellLayout.TitleStringAttributes)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec.vertical()
        stack.alignItems = .center
        stack.justifyContent = .center
        
        imageNode.style.preferredSize = Constants.CategorySmallCellLayout.CategorySmallImageSize
        
        stack.children = [imageNode, titleLabel]
        
        let rowInsets = UIEdgeInsets(top: 6, left: 4, bottom: 6, right: 4)
        return ASInsetLayoutSpec(insets: rowInsets, child: stack)
    }
}

