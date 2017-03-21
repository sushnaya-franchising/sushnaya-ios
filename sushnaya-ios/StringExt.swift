//
//  StringExt.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/21/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation


extension String {
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
