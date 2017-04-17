//
// Created by Igor Kurylenko on 3/30/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let GoldenRatio = CGFloat(1.61803398875)
    
    static let CartButtonDragDistanceToPopCartItem: CGFloat = 5
    
    static let CartButtonBadgeStringAttributes = [
        NSForegroundColorAttributeName: PaperColor.Gray900,
        NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)
    ]
    
    struct LocalityCellLayout {
        static let CoatOfArmsImageSize = CGSize(width: 32, height: 32)
        static let ImageCornerRadius:CGFloat = 10
    }
    
    struct FilterCellLayout {
        static let CellInsets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        static let ImageSize = CGSize(width: 64, height: 64)
        static let ImageCornerRadius:CGFloat = 15
        
        static let TitleStringAttributes:[String: Any] = {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            return [
                NSForegroundColorAttributeName: PaperColor.Gray800,
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12),
                NSParagraphStyleAttributeName : paragraphStyle
            ]
        }()

        static let TitleLabelInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)

        static let BackgroundColor = PaperColor.White
        static let SelectedBackgroundColor = PaperColor.Gray300
    }
    
    struct ProductCellLayout {
        static let CellInsets = UIEdgeInsets(top: 6, left: 6, bottom: 12, right: 6)

        static let BackgroundColor = PaperColor.White
        static let SelectedBackgroundColor = PaperColor.Gray300
        static let PriceButtonBackgroundColor = PaperColor.Gray300

        static let ImageCornerRadius:CGFloat = 15

        static let TitleFontSize:CGFloat = 14
        static let SubtitleFontSize:CGFloat = 12
        
        static let TitleStringAttributes = [
                NSForegroundColorAttributeName: PaperColor.Gray800,
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: TitleFontSize)
        ]

        static let SubtitleStringAttributes = [
            NSForegroundColorAttributeName: PaperColor.Gray600,
            NSFontAttributeName: UIFont.systemFont(ofSize: 12)
        ]
        
        static let PriceStringAttributes = [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
        ]

        static let PriceWithModifierStringAttributes = [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
        ]
        
        static let PriceModifierStringAttributes = [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)
        ]                
        
        static let TitleLabelInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        static let SubtitleLabelInsets = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        static let PricingInsets = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 0)
        
        static let PricingRowSpacing: CGFloat = 0
        static let PricingNodeSpacing: CGFloat = 4
        
        static let PriceButtonInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        static let PriceButtonContentInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        static let PriceButtonHitTestSlopPadding = (44.0 - (14 + PriceButtonContentInsets.top + PriceButtonContentInsets.bottom))/2.0
        static let ModifierTextInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        static let CheckIconSize = CGSize(width: 18, height: 18)
        static let CheckIconColor = PaperColor.Gray800
    }
    
    struct CartLayout {
        static let backgroundColor = PaperColor.White
        
        static let SectionTitleBackgroundColor = PaperColor.White
        
        static let HeaderStringAttributes = [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)
        ]                
        
        static let EmptyCartStringAttributes: [String: Any] = {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            return [
                NSForegroundColorAttributeName: PaperColor.Gray,
                NSFontAttributeName: UIFont.systemFont(ofSize: 14),
                NSParagraphStyleAttributeName : paragraphStyle
            ]
        }()
        
        static let SectionTitleStringAttributes = [
            NSForegroundColorAttributeName: PaperColor.Gray,
            NSFontAttributeName: UIFont.systemFont(ofSize: 12)
        ]
        
        static let ItemTitleStringAttributes = [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.systemFont(ofSize: 12)
        ]
        
        static let ItemPriceStringAttributes = [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.systemFont(ofSize: 12)
        ]
        
        static let ItemCountStringAttributes = [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.systemFont(ofSize: 12)
        ]
        
        static let ItemPriceModifierNameStringAttributes = [
            NSForegroundColorAttributeName: PaperColor.Gray,
            NSFontAttributeName: UIFont.systemFont(ofSize: 10)
        ]
        
        static let SectionTitleInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        static let SectionTitleHeight:CGFloat = 32
        static let ItemCountInsets = UIEdgeInsets(top: 12, left: 24, bottom: 0, right: 16)
        static let ItemTitleInsets = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 16)
        static let ItemPriceInsets = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        
        static let HeaderTextContainerInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        static let EmptyCartMessageWidthFraction:CGFloat = 0.7
        
        static let BottomSpacerHeight:CGFloat = 32
        
        
        static let DeliveryButtonBackgroundColor = PaperColor.Gray300
        
        static let DeliveryButtonTitileStringAttributes = [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)
        ]
    }
}
