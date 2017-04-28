//
//  Product.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/25/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

class Product: Hashable {
    var title: String
    var subtitle: String?
    var photoUrl: String?
    var photoSize: CGSize?
    var pricing: [Price]
    var category: MenuCategory

    var categoryTitle:String {
        return category.title
    }
    
    var highestPrice: Price? {
        var result: Price?
        var highestValue: CGFloat = 0
        
        pricing.forEach {
            if $0.value >= highestValue {
                highestValue = $0.value
                result = $0
            }
        }
        
        return result
    }
    
    convenience init(title: String, pricing: [Price], category: MenuCategory) {
        self.init(title: title, pricing: pricing, category: category, subtitle: nil, photoUrl: nil, photoSize: nil)
    }

    init(title: String, pricing: [Price], category: MenuCategory, subtitle: String?, photoUrl: String?, photoSize: CGSize?) {
        self.title = title
        self.pricing = pricing
        self.subtitle = subtitle
        self.photoUrl = photoUrl
        self.photoSize = photoSize
        self.category = category
    }
    
    public var description: String {
        return title
    }
    
    var hashValue: Int {
        var result = 1
        result = 31 &* result &+ title.hashValue
        result = 31 &* result &+ (subtitle?.hashValue ?? 0)
        result = 31 &* result &+ (photoUrl?.hashValue ?? 0)
        result = 31 &* result &+ (photoSize?.hashValue ?? 0)
        result = 31 &* result &+ HashValueUtil.hashValue(of: pricing)
        result = 31 &* result &+ category.hashValue
        
        return result
    }
}

func ==(lhs: Product, rhs: Product) -> Bool {
    if lhs === rhs {
        return true
    }
    
    return lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.photoSize == rhs.photoSize &&
        lhs.photoUrl == rhs.photoUrl &&
        lhs.pricing == rhs.pricing &&
        lhs.category == rhs.category
}
