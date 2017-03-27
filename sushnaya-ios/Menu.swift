//
//  Menu.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/25/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation


class Menu {
    var locality: Locality
    var categories: [MenuCategory]?
    
    convenience init(locality: Locality) {
        self.init(locality: locality, categories: nil)
    }
    
    init(locality: Locality, categories: [MenuCategory]?) {
        self.locality = locality
        self.categories = categories
    }
}
