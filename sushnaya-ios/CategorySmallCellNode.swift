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

    let imageNode: ASImageNode = {// todo: make it ASNetworkingNode
        let imageNode = ASImageNode()
        imageNode.contentMode = .scaleAspectFit
        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(cornerRadius: 20)
        return imageNode
    }()

    let titleLabel = ASTextNode()

    lazy var titleStringAttributes: [String: AnyObject] = {
        return [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 10)
        ]
    }()
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? PaperColor.Gray200: PaperColor.White
        }
    }
    
    init(category: MenuCategory) {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
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

    private func setupTitleLabel(_ category: MenuCategory) {
        titleLabel.attributedText = NSAttributedString(string: category.title, attributes: titleStringAttributes)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec.vertical()
        stack.alignItems = .center
        stack.justifyContent = .center
        
        imageNode.style.preferredSize = Constants.CellLayout.CategorySmallImageSize
        
        stack.children = [imageNode, titleLabel]
        
        let rowInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        return ASInsetLayoutSpec(insets: rowInsets, child: stack)
    }
}

