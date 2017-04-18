//
//  DataStructure.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/18/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation


struct Two<T:Hashable,U:Hashable> : Hashable {
    let values : (T, U)
    
    var hashValue : Int {
        get {
            let (a,b) = values
            return a.hashValue &* 31 &+ b.hashValue
        }
    }
}

// comparison function for conforming to Equatable protocol
func ==<T:Hashable,U:Hashable>(lhs: Two<T,U>, rhs: Two<T,U>) -> Bool {
    return lhs.values == rhs.values
}
