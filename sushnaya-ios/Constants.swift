//
// Created by Igor Kurylenko on 3/30/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let GoldenRatio = CGFloat(1.61803398875)
    
    struct LocalityCellLayout {
        static let CoatOfArmsImageSize = CGSize(width: 32, height: 32)
        static let ImageCornerRadius:CGFloat = 10
    }
    
    struct CategoryCellLayout {
        static let CellInsets = UIEdgeInsets(top: 6, left: 6, bottom: 14, right: 6)
        
        static let BackgroundColor = PaperColor.White
        static let SelectedBackgroundColor = PaperColor.Gray300
        
        static let ImageCornerRadius:CGFloat = 15

        static let TitleStringAttributes = [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
        ]

        static let SubtitleStringAttributes = [
            NSForegroundColorAttributeName: PaperColor.Gray600,
            NSFontAttributeName: UIFont.systemFont(ofSize: 12)
        ]
        
        static let TitleLabelInsets = UIEdgeInsets(top: 8, left: 5, bottom: 0, right: 5)
        static let SubtitleLabelInsets = UIEdgeInsets(top: 4, left: 5, bottom: 0, right: 5)
    }

    struct CategorySmallCellLayout {
        static let CategorySmallImageSize = CGSize(width: 64, height: 64)
        static let ImageCornerRadius:CGFloat = 15
        static let TitleStringAttributes = [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)
        ]
        
        static let BackgroundColor = PaperColor.White
        static let SelectedBackgroundColor = PaperColor.Gray300
    }
    
    struct ProductCellLayout {
        static let CellInsets = UIEdgeInsets(top: 6, left: 6, bottom: 16, right: 6)

        static let BackgroundColor = PaperColor.White
        static let SelectedBackgroundColor = PaperColor.Gray300

        static let ImageCornerRadius:CGFloat = 15

        static let TitleStringAttributes = [
                NSForegroundColorAttributeName: PaperColor.Gray800,
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
        ]

        static let PriceStringAttributes = [
                NSForegroundColorAttributeName: PaperColor.Gray800,
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
        ]

        static let SubtitleStringAttributes = [
                NSForegroundColorAttributeName: PaperColor.Gray600,
                NSFontAttributeName: UIFont.systemFont(ofSize: 12)
        ]

        static let TitleLabelInsets = UIEdgeInsets(top: 8, left: 5, bottom: 0, right: 5)
        static let PriceLabelInsets = UIEdgeInsets(top: 4, left: 5, bottom: 0, right: 5)
        static let SubtitleLabelInsets = UIEdgeInsets(top: 4, left: 5, bottom: 0, right: 5)
    }
}
