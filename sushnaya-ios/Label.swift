//
//  ABLabel.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/15/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation


class Label: UILabel {
    var insets:UIEdgeInsets?
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets ?? UIEdgeInsets.zero))
    }
}
