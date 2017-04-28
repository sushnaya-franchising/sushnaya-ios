//
//  CategorySideTableCellNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/1/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class DefaultCellNode: ASCellNode {
    let imageNode: ASImageNode = {// todo: make it ASNetworkingNode
        let imageNode = ASImageNode()
        imageNode.contentMode = .scaleAspectFit
//        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(
//            cornerRadius: Constants.LocalityCellLayout.ImageCornerRadius)
        return imageNode
    }()

    let titleLabel = ASTextNode()    
    
    let context: DefaultCellContext
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? context.style.selectedBackground: context.style.backgroundColor
        }
    }
    
    init(context: DefaultCellContext) {
        self.context = context
        
        super.init()
        
        self.automaticallyManagesSubnodes = true
        self.selectionStyle = .none
        self.backgroundColor = context.style.backgroundColor
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupImageNode()
        setupTitleLabel()
    }
    
    private func setupImageNode() {
        //imageNode.defaultImage = UIImage(color: PaperColor.Gray300, size: Constants.CellLayout.CoatOfArmsImageSize)
        
        if let image = context.image {
            let size = image.size
            if size.width < context.style.imageSize.width ||
                size.height < context.style.imageSize.height {
                imageNode.backgroundColor = PaperColor.Gray300
                imageNode.contentMode = .center
            }
            
            imageNode.image = image
        
        } else if let url = context.imageUrl {
        //    imageNode.url = URL(string: url)
            imageNode.image = UIImage(named: url)
        }
    }

    override func didLoad() {
        super.didLoad()
        
        imageNode.layer.cornerRadius = context.style.imageCornerRadius // todo: use optimized corner radius, update corner radius in ASNetworkImageNodeDelegate
        imageNode.clipsToBounds = true
    }
    
    private func setupTitleLabel() {
        titleLabel.attributedText = NSAttributedString(string: context.title, attributes: context.style.titleStringAttributes)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec { 
        let stack = ASStackLayoutSpec.vertical()
        stack.alignItems = .center
        stack.justifyContent = .start
        
        imageNode.style.preferredSize = context.style.imageSize
        
        titleLabel.style.maxWidth = ASDimension(unit: .points, value: context.style.imageSize.width)
        
        stack.children = [
                imageNode,
                ASInsetLayoutSpec(insets: context.style.titleInsets, child: titleLabel)
        ]
        
        return ASInsetLayoutSpec(insets: context.style.insets, child: stack)
    }
}

class DefaultCellContext {
    var title: String
    var imageSize: CGSize?
    var imageUrl: String?
    var image: UIImage?
    var style = DefaultCellStyle()
    
    init(title: String) {
        self.title = title
    }
    
    convenience init(title: String, style: DefaultCellStyle) {
        self.init(title: title)
        self.style = style
    }
}

struct DefaultCellStyle {
    var imageSize = Constants.DefaultCellLayout.ImageSize
    var imageCornerRadius = Constants.DefaultCellLayout.ImageCornerRadius
    var backgroundColor = Constants.DefaultCellLayout.BackgroundColor
    var selectedBackground = Constants.DefaultCellLayout.SelectedBackgroundColor
    var insets = Constants.DefaultCellLayout.CellInsets
    var titleInsets = Constants.DefaultCellLayout.TitleLabelInsets
    var titleStringAttributes = Constants.DefaultCellLayout.TitleStringAttributes
}


