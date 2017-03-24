//
//  Debouncer.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/22/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation


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
    
    func apply() {
        cancel()
        
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { timer in
            self.callback()
        }
    }
    
    func cancel() {
        timer?.invalidate()
        onCancel?()
    }
    
    func onCancel(onCancel: @escaping (()->())) -> Debouncer{
        self.onCancel = onCancel
        
        return self
    }
}
