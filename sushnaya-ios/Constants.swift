//
// Created by Igor Kurylenko on 3/30/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let GoldenRatio = CGFloat(1.61803398875)
    
    struct CellLayout {
        static let CoatOfArmsImageSize = CGSize(width: 32, height: 32)
        static let CategorySmallImageSize = CGSize(width: 60, height: 60)
    }
    
    struct CategoryCellLayout {
        static let CellInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        static let BackgroundColor = PaperColor.White
        static let SelectedBackgroundColor = PaperColor.Gray200
        
        static let ImageCornerRadius:CGFloat = 20
        
        static let TitleStringAttributes = [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)
        ]
        static let SubtitleStringAttributes = [
            NSForegroundColorAttributeName: PaperColor.Gray600,
            NSFontAttributeName: UIFont.systemFont(ofSize: 10)
        ]
        
        static let TitleLabelInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        static let SubtitleLabelInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
    }
}
