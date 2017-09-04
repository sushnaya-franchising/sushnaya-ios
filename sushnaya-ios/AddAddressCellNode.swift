//
//  AddAddressCellNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 7/1/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class AddAddressCellNode: ASCellNode {
    static let LabelStringAttributes = [
        NSForegroundColorAttributeName: PaperColor.Gray,
        NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
    ]
    
    fileprivate let labelTextNode = ASTextNode()
    
    override init() {
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        labelTextNode.attributedText = NSMutableAttributedString(string: "Добавить адрес",
                                                                 attributes: AddAddressCellNode.LabelStringAttributes)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: labelTextNode)
    }
}
