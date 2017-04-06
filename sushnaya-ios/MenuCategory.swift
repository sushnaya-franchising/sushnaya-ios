//
//  MenuCategory.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/25/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class MenuCategory {
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
}
