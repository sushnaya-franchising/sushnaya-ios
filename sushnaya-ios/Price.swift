//
// Created by Igor Kurylenko on 4/8/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation

class Price {
    var value: CGFloat
    var modifier: String?
    var currencyLocale: String
    
    var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value.asNSNumber)!
    }

    init(value: CGFloat, currencyLocale: String, modifier: String? = nil) {
        self.value = value
        self.modifier = modifier
        self.currencyLocale = currencyLocale
    }
}
