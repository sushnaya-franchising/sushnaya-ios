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
    var pricing: [Price]

    convenience init(title: String, pricing: [Price]) {
        self.init(title: title, pricing: pricing, subtitle: nil, photoUrl: nil, photoSize: nil)
    }

    init(title: String, pricing: [Price], subtitle: String?, photoUrl: String?, photoSize: CGSize?) {
        self.title = title
        self.pricing = pricing
        self.subtitle = subtitle
        self.photoUrl = photoUrl
        self.photoSize = photoSize
    }
}
