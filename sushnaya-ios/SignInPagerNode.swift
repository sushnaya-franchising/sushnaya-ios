//
//  SignInPagerNode.swift
//  Food
//
//  Created by Igor Kurylenko on 3/28/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit


class SignInPagerNode: ASDisplayNode {
    static let introHeadings = [
        (header: "Добро пожаловать в Сушную!", subheading: "Здесь лучшие роллы по самой низкой цене"),
        (header: "Более 300 видов блюд", subheading: "70 видов роллов, 30 видов пиццы"),
        (header: "Бесплатная доставка", subheading: "При заказе от 600₽")
    ]
    
    let pagerNode = ASPagerNode()
    var pageControl: UIPageControl?
    
    override init() {
        super.init()
        
        automaticallyManagesSubnodes = true
        
        pagerNode.allowsAutomaticInsetsAdjustment = true
        pagerNode.backgroundColor = UIColor.clear
        pagerNode.setDataSource(self)
        pagerNode.setDelegate(self)
    }

    override func didLoad() {
        super.didLoad()
        
        let pageControl = UIPageControl()
        self.pageControl = pageControl
        pageControl.numberOfPages = SignInPagerNode.introHeadings.count
        pageControl.currentPage = 0
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        pagerNode.style.width = ASDimensionMakeWithFraction(1.0)
        pagerNode.style.height = ASDimensionMakeWithFraction(1.0)
        
        return ASWrapperLayoutSpec(layoutElement: pagerNode)
    }
    
    override func layout() {
        super.layout()
        
        if let pageControl = self.pageControl {
            let bounds = pagerNode.bounds
            var refreshRect = pageControl.frame
            refreshRect.origin = CGPoint(x: (bounds.size.width - pageControl.frame.size.width) / 2.0,
                                         y: (bounds.size.height - 104))
            pageControl.frame = refreshRect
            
            view.addSubview(pageControl)
        }
    }
}

extension SignInPagerNode : ASPagerDataSource, ASPagerDelegate {
    func numberOfPages(in pagerNode: ASPagerNode) -> Int {
        return SignInPagerNode.introHeadings.count
    }
    
    func pagerNode(_ pagerNode: ASPagerNode, nodeAt index: Int) -> ASCellNode {
        let (header, subheading) = SignInPagerNode.introHeadings[index]
        
        return SignInPageNode(header: header, subheading: subheading)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl?.currentPage = Int(pageNumber)
    }
}

class SignInPageNode: ASCellNode {
    let headerTextNode = ASTextNode()
    let subheadingTextNode = ASTextNode()
    
    init(header: String, subheading: String) {
        super.init()
        
        automaticallyManagesSubnodes = true
        neverShowPlaceholders = true
        
        initHeaderTextNode(header)
        initSubheadingTextNode(subheading)
    }
    
    private func initHeaderTextNode(_ header: String) {
        headerTextNode.attributedText = NSAttributedString.attributedString(string: header, fontSize: 17, color: UIColor.white)
        headerTextNode.maximumNumberOfLines = 0
        initHeadingTextNodeLayer(layer: headerTextNode.layer)
    }
    
    private func initSubheadingTextNode(_ subheading: String) {
        subheadingTextNode.attributedText = NSAttributedString.attributedString(string: subheading, fontSize: 14, color: UIColor.white, bold: false)
        subheadingTextNode.maximumNumberOfLines = 0
        initHeadingTextNodeLayer(layer: subheadingTextNode.layer)
        subheadingTextNode.layer.opacity = 0.8
    }
    
    private func initHeadingTextNodeLayer(layer: CALayer) {
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 3
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        headerTextNode.textContainerInset = UIEdgeInsetsMake(0, 32, 0, 32)
        subheadingTextNode.textContainerInset = UIEdgeInsetsMake(0, 32, 0, 32)
        
        let stack = ASStackLayoutSpec(direction: .vertical,
                                      spacing: 5,
                                      justifyContent: .end,
                                      alignItems: .start,
                                      children: [headerTextNode, subheadingTextNode])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 0, 124, 0), child: stack)
    }
}
