//
//  StringExt.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/21/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import UIKit

let EmptyString = ""

extension String {
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }

    func replace(_ string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement,
                                         options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespaces() -> String {
        return self.replace(" ", replacement: "")
    }
    
    var asCAMediaTimingFunction: CAMediaTimingFunction {
        return CAMediaTimingFunction(name: self)
    }
    
    var firstLetters: String {
        var result = String()
        var shouldAddLetter = true
        
        characters.forEach { ch in
            switch ch {
            case " ":
                shouldAddLetter = true
                
            case _ where shouldAddLetter:
                shouldAddLetter = false
                result.append(ch)
                
            default:
                break
            }
        }
        
        return result
    }
    
    func calculateHeight(attributes: [String: Any]?, width: CGFloat) -> CGFloat {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return ceil(rect.height)
    }
    
    func boundingRect(attributes: [String: Any]?, width: CGFloat) -> CGRect {
        return NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
    }
    
    func boundingRect(attributes: [String: Any]?) -> CGRect {
        return NSString(string: self).boundingRect(with: CGSize.max, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
    }
    
    func stringByReplacingMatchesInString(pattern: String, replaceWith: String = "") -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, self.characters.count)

            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch {
            return self
        }
    }
}
