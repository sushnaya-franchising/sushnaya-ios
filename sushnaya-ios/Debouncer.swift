//
//  Debouncer.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/22/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

typealias debounce = Debouncer

class Debouncer {
    private weak var timer: Timer?
    private var callback: (() -> ())
    private var delay: Double
    private var onCancel: (() -> ())?
    
    convenience init(callback: @escaping (() -> ())) {
        self.init(delay: 0.2, callback: callback)
    }
    
    convenience init(delay: Double, callback: @escaping (() -> ())) {
        self.init(delay: delay, callback: callback, onCancel: nil)
    }
    
    init(delay: Double, callback: @escaping (() -> ()), onCancel: (()->())?) {
        self.delay = delay
        self.callback = callback
        self.onCancel = onCancel
    }
    
    @discardableResult func apply() -> Debouncer {
        cancel()
        
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { timer in
            self.callback()
        }
        
        return self
    }
    
    @discardableResult func cancel() -> Debouncer {
        timer?.invalidate()
        onCancel?()
        
        return self
    }
    
    @discardableResult func onCancel(onCancel: @escaping (()->())) -> Debouncer {
        self.onCancel = onCancel
        
        return self
    }
}
