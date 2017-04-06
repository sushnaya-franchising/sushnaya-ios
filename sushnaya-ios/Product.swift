//
//  Product.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/25/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

class Product {
    var title: String
    var subtitle: String?
    var photoUrl: String?
    var photoSize: CGSize?
    var price: CGFloat
    var currencyLocale: String

    var formattedPrice:String {
        get{
            let formatter = NumberFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.numberStyle = .currency
            
            return formatter.string(from: self.price.asNSNumber)!
        }
    }
    
    convenience init(title: String, price:CGFloat, currencyLocale: String) {
        self.init(title: title, price: price, currencyLocale: currencyLocale, subtitle: nil, photoUrl: nil, photoSize: nil)
    }

    init(title: String, price:CGFloat, currencyLocale: String, subtitle: String?, photoUrl: String?, photoSize: CGSize?) {
        self.title = title
        self.price = price
        self.currencyLocale = currencyLocale
        self.subtitle = subtitle
        self.photoUrl = photoUrl
        self.photoSize = photoSize
    }
}
