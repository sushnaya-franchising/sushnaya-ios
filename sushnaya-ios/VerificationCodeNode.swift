//
//  VerificationCodeNode.swift
//  Food
//
//  Created by Igor Kurylenko on 3/29/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class VerificationCodeNode: ASCellNode {    
    let textNode = ASEditableTextNode()
    let promptTextNode = ASTextNode()
    let phoneNumber: String
    
    lazy var textNodeStringAttributes: [String : AnyObject] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        return [
            NSFontAttributeName : UIFont.systemFont(ofSize: 27),
            NSParagraphStyleAttributeName : paragraphStyle,
            NSForegroundColorAttributeName: PaperColor.Black
        ]
    }()
    
    lazy var textNodePlaceholderStringAttributes: [String : AnyObject] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        return [
            NSFontAttributeName : UIFont.systemFont(ofSize: 27),
            NSParagraphStyleAttributeName : paragraphStyle,
            NSForegroundColorAttributeName: PaperColor.Gray300
        ]
    }()
    
    lazy var promptTextAttributes: [String : AnyObject] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        return [
            NSFontAttributeName : UIFont.systemFont(ofSize: 17),
            NSParagraphStyleAttributeName : paragraphStyle,
            NSForegroundColorAttributeName: PaperColor.Gray500
        ]
    }()
    
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        super.init()
        
        selectionStyle = .none
        automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupTextNode()
        setupPromptTextNode()
    }
    
    private func setupTextNode() {
        textNode.attributedPlaceholderText = NSAttributedString(string: "Код", attributes: textNodePlaceholderStringAttributes)
        textNode.typingAttributes = textNodeStringAttributes
        textNode.keyboardType = UIKeyboardType.numberPad
    }
    
    private func setupPromptTextNode() {
        promptTextNode.attributedText = NSAttributedString(string: "На номер \(phoneNumber) было отправлено SMS с кодом.", attributes: promptTextAttributes)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        textNode.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        textNode.style.alignSelf = ASStackLayoutAlignSelf.stretch
        promptTextNode.textContainerInset = UIEdgeInsets(top: 30, left: 16, bottom: 0, right: 16)
        
        let stack = ASStackLayoutSpec(direction: .vertical, spacing: 30, justifyContent: .start, alignItems: .center,
                                      children: [promptTextNode, textNode])
        
        return stack
    }
}
