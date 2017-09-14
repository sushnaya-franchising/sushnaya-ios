//
//  NSAttributedStringExt.swift
//  Food
//
//  Created by Igor Kurylenko on 3/28/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
    
    static func attributedString(string: String?, fontSize size: CGFloat, color: UIColor?, bold: Bool = true) -> NSAttributedString? {
        guard let string = string else { return nil }
        
        let attributes = [NSForegroundColorAttributeName: color ?? UIColor.black,
                          NSFontAttributeName: (bold ? UIFont.boldSystemFont(ofSize: size): UIFont.systemFont(ofSize: size))]
        
        let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
        
        return attributedString
    }
    
    func calculateHeight(width: CGFloat) -> CGFloat {
        let attributes = self.attributes(at: 0, longestEffectiveRange: nil, in: NSRange(location: 0, length: self.length))

        let rect = NSString(string: self.string).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return ceil(rect.height)
    }
    
}
