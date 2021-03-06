//
//  ASButtonNodeExt.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/28/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

typealias TargetClosure = (ASControlNode) -> ()

class ClosureWrapper: NSObject {
    let closure: TargetClosure
    init(_ closure: @escaping TargetClosure) {
        self.closure = closure
    }
}

extension ASControlNode {
    
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
    
    private var targetClosure: TargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, ClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setTargetClosure(closure: @escaping TargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(ASControlNode.closureAction), forControlEvents: .touchUpInside)
    }
    
    func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }
}
