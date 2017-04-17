//
//  MenuCategory.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/25/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class MenuCategory: Hashable {
    var title: String
    var subtitle: String?
    var photoUrl: String?
    var photoSize: CGSize?
    
    convenience init(title: String) {
        self.init(title: title, subtitle: nil, photoUrl: nil, photoSize: nil)
    }
    
    init(title: String, subtitle: String?, photoUrl: String?, photoSize: CGSize?) {
        self.title = title
        self.subtitle = subtitle
        self.photoUrl = photoUrl
        self.photoSize = photoSize
    }
    
    var hashValue: Int {
        var result = 1
        result = 31 &* result &+ title.hashValue
        result = 31 &* result &+ (subtitle?.hashValue ?? 0)
        result = 31 &* result &+ (photoUrl?.hashValue ?? 0)
        result = 31 &* result &+ (photoSize?.hashValue ?? 0)
        
        return result
    }
}

func ==(lhs: MenuCategory, rhs: MenuCategory) -> Bool {
    if lhs === rhs {
        return true
    }
    
    return lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.photoSize == rhs.photoSize &&
        lhs.photoUrl == rhs.photoUrl
}
