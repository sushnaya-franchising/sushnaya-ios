//
//  PhoneNumberCellNode.swift
//  Food
//
//  Created by Igor Kurylenko on 3/29/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PhoneNumberNode: ASCellNode {
    let textNode = ASEditableTextNode()
    let promptTextNode = ASTextNode()
    let termsOfUseButton = ButtonNode()
    
    lazy var textNodeStringAttributes: [String : AnyObject] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        return [
            NSFontAttributeName : UIFont.systemFont(ofSize: 27),
            NSParagraphStyleAttributeName : paragraphStyle,
            NSForegroundColorAttributeName: PaperColor.Black
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
    
    lazy var termsOfUseButtonTitleAttributes: [String : AnyObject] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        return [
            NSFontAttributeName : UIFont.systemFont(ofSize: 13),
            NSParagraphStyleAttributeName : paragraphStyle,
            NSForegroundColorAttributeName: PaperColor.Blue500
        ]
    }()

    
    override init() {
        super.init()
        
        selectionStyle = .none
        automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupTextNode()
        setupPromptTextNode()
        setupTermsOfUseButtonNode()
    }
    
    private func setupTextNode() {
        textNode.attributedText = NSAttributedString(string: "+7 ", attributes: textNodeStringAttributes)
        textNode.keyboardType = UIKeyboardType.numberPad                        
    }
    
    private func setupPromptTextNode() {
        promptTextNode.attributedText = NSAttributedString(string: "Укажите ваш номер телефона, пожалуйста.", attributes: promptTextAttributes)
    }
    
    private func setupTermsOfUseButtonNode() {
        let termsOfUseText = NSAttributedString(string: "Регистрируясь, вы соглашаетесь с Правилами использования сервиса.", attributes: termsOfUseButtonTitleAttributes)
        termsOfUseButton.setAttributedTitle(termsOfUseText, for: .normal)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        textNode.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        textNode.style.alignSelf = ASStackLayoutAlignSelf.stretch
        promptTextNode.textContainerInset = UIEdgeInsets(top: 30, left: 16, bottom: 0, right: 16)
        termsOfUseButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let stack = ASStackLayoutSpec(direction: .vertical, spacing: 30, justifyContent: .start, alignItems: .center,
                                      children: [promptTextNode, textNode, termsOfUseButton])
        
        return stack
    }
}
