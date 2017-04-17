//
//  QueryFilter.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 4/6/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation

class CellData {
    var title: String
    var imageSize: CGSize?
    var imageUrl: String?
    var image: UIImage?
    
    init(title: String) {
        self.title = title
    }
}

class CategoryCellData: CellData {
    override var title: String {
        set {
            category.title = newValue
        }
        
        get {
            return category.title
        }
    }

    override var imageSize: CGSize? {
        set {
            category.photoSize = newValue
        }
        
        get{
            return category.photoSize
        }
    }

    override var imageUrl: String? {
        set {
            category.photoUrl = newValue
        }
        
        get {
            return category.photoUrl
        }
    }
    
    let category: MenuCategory

    init(_ category: MenuCategory) {
        self.category = category
        super.init(title: category.title)
    }
}
