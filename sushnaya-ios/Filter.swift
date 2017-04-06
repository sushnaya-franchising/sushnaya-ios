//
//  QueryFilter.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/6/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

protocol Filter {
    associatedtype Payload
    
    var name:String { get }
    
    var imageSize:CGSize? { get }
    
    var imageUrl:String? { get }
    
    var payload: Payload { get }
}

class FilterByCategory: Filter {
    typealias Payload = MenuCategory
    
    var payload: MenuCategory {
        return category
    }
    
    var name: String {
        return category.title
    }
    
    var imageSize: CGSize? {
        return category.photoSize
    }
    
    var imageUrl: String? {
        return category.photoUrl
    }
    
    private var category: MenuCategory
    
    init(_ category: MenuCategory) {
        self.category = category
    }
}
