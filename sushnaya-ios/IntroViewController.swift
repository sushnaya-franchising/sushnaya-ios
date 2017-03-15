//
//  IntroViewController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/15/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import UIKit
import RazzleDazzle


class IntroViewController: AnimatedPagingScrollViewController {
    private let firstLabel = UILabel()
    private let secondLabel = UILabel()
    private let thirdLabel = UILabel()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    private func configureViews() {
        firstLabel.text = "Про продукцию"
        secondLabel.text = "Про условия бесплатной доставки"
        thirdLabel.text = "Как добавить в корзину"
        
        contentView.addSubview(firstLabel)
        contentView.addSubview(secondLabel)
        contentView.addSubview(thirdLabel)
        
        contentView.addConstraint(NSLayoutConstraint(item: firstLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: secondLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: thirdLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        
        keepView(firstLabel, onPage: 0)
        keepView(secondLabel, onPage: 1)
        keepView(thirdLabel, onPage: 2)
    }
    
    override func numberOfPages() -> Int {
        return 3
    }
}
