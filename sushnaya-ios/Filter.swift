//
//  QueryFilter.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/6/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

protocol Filter {
    var title: String { get }
    var imageSize: CGSize? { get }
    var imageUrl: String? { get }
}

class FilterByCategory: Filter {
    var title: String {
        return category.title
    }

    var imageSize: CGSize? {
        return category.photoSize
    }

    var imageUrl: String? {
        return category.photoUrl
    }

    let category: MenuCategory

    init(_ category: MenuCategory) {
        self.category = category
    }
}
