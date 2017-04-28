//
// Created by Igor Kurylenko on 3/30/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit

class LocalityCellNode: ASCellNode {

    var titleLabel = ASTextNode()

    var imageNode: ASNetworkImageNode = {
        let imageNode = ASNetworkImageNode()
        imageNode.contentMode = .scaleAspectFit
        imageNode.imageModificationBlock = ImageNodePrecompositedCornerModification(cornerRadius: 10)
        return imageNode
    }()

    lazy var titleStringAttributes: [String: AnyObject] = {
        return [
                NSFontAttributeName: UIFont.systemFont(ofSize: 17)
        ]
    }()

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? PaperColor.Gray100: PaperColor.White
        }
    }

    init(locality: Locality) {
        super.init()

        self.selectionStyle = .none
        self.automaticallyManagesSubnodes = true

        setupNodes(locality)
    }

    private func setupNodes(_ locality: Locality) {
        setupTitleLabel(locality)
        setupImageNode(locality)
    }

    private func setupTitleLabel(_ locality: Locality) {
        titleLabel.attributedText = NSAttributedString(string: locality.name, attributes: titleStringAttributes)
    }

    private func setupImageNode(_ locality: Locality) {
        imageNode.defaultImage = UIImage(color: PaperColor.Gray300, size: Constants.LocalityCellLayout.CoatOfArmsImageSize)

        if let url = locality.coatOfArmsUrl {
            imageNode.url = URL(string: url)
        }
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec.horizontal()
        stack.justifyContent = .start
        stack.alignItems = .center

        imageNode.style.preferredSize = Constants.LocalityCellLayout.CoatOfArmsImageSize
        let imageNodeInsets = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 16)
        let imageNodeLayoutSpec = ASInsetLayoutSpec(insets: imageNodeInsets, child: imageNode)

        stack.children = [imageNodeLayoutSpec, titleLabel]

        let rowInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        return ASInsetLayoutSpec(insets: rowInsets, child: stack)
    }
}
