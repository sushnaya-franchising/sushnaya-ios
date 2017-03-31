//
//  ASEditableTextNodeExt.swift
//  Food
//
//  Created by Igor Kurylenko on 3/29/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

extension ASEditableTextNode {
    func setTextWhileKeepingAttributes(text: String) {        
        if let curAttributedText = self.attributedText {
            let mutableAttributedText = curAttributedText.mutableCopy() as! NSMutableAttributedString
            mutableAttributedText.mutableString.setString(text)
            self.attributedText = mutableAttributedText
            
        } else {
            self.attributedText = NSAttributedString(string: text, attributes: self.typingAttributes)
        }
    }
}
