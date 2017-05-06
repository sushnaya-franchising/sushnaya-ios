//
//  UIViewExt.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 5/5/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

extension UIView {
    func currentFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }
        
        for view in self.subviews {
            if let responder = view.currentFirstResponder() {
                return responder
            }
        }
        
        return nil
    }
}
