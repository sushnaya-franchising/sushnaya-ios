//
//  IntroViewController.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 3/15/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import UIKit
import RazzleDazzle
import Crashlytics
import DigitsKit
import AVKit
import AVFoundation


class SignInViewController: AnimatedPagingScrollViewController {
    private let introHeadings = [
        (header: "Добро пожаловать в Сушную!", subheading: "Лучшие роллы по самой низкой цене"),
        (header: "Более 300 видов блюд", subheading: "70 видов роллов, 30 видов пиццы"),
        (header: "Бесплатная доставка", subheading: "При заказе от 600₽")
    ]
    
    private let digitsAuthenticationConfig: DGTAuthenticationConfiguration = {
        let appearance = DGTAppearance()
        appearance.backgroundColor = UIColor.fromUInt(0xFFFFFF)
        appearance.accentColor = UIColor.fromUInt(0x007AFF)
        
        let configuration = DGTAuthenticationConfiguration(accountFields: .defaultOptionMask)
        configuration?.appearance = appearance
        configuration?.phoneNumber = "+7"
        configuration?.title = ""
        
        return configuration!
    }()
    
    var signInButton = UIButton()
    var pageControl = UIPageControl()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func numberOfPages() -> Int {
        return introHeadings.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        
        animateCurrentFrame() // walk around RazzleDazzle bug
    }
    
    private func configureViews() {
        configureIntroVideoPlayerView()
        
        configureHeadingViews()
        
        configureSignInButton()
        
        configurePageControl()
    }
    
    private func configurePageControl() {
        guard introHeadings.count > 1 else {return}
        
        pageControl.numberOfPages = introHeadings.count
        pageControl.currentPage = 0
        
        pageControl.addTarget(self, action: #selector(SignInViewController.changePage(sender:)), for: UIControlEvents.valueChanged)
        
        contentView.addSubview(pageControl)
        
        let vertConstr = NSLayoutConstraint(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -84)
        
        NSLayoutConstraint.activate([vertConstr])
        
        keepView(pageControl, onPages: (0...introHeadings.count).map{CGFloat($0)})
    }
    
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    private func configureSignInButton() {
        signInButton.setTitle("Войти", for: .normal)
        signInButton.setTitleColor(UIColor.white, for: .normal)
        signInButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        signInButton.titleLabel?.layer.shadowOffset = CGSize(width: 0, height: 0)
        signInButton.titleLabel?.layer.shadowOpacity = 0.7
        signInButton.titleLabel?.layer.shadowRadius = 3
        signInButton.layer.cornerRadius = 5;
        
        signInButton.addTarget(self, action: #selector(SignInViewController.signInButtonTapped(_:)), for: .touchUpInside)
        
        contentView.addSubview(signInButton)
        
        let vertConstr = NSLayoutConstraint(item: signInButton, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -20)
        let widthConstr = NSLayoutConstraint(item:signInButton, attribute: .width, relatedBy: .equal, toItem: scrollView.superview, attribute: .width, multiplier: 0.8, constant: 0)
        let heightConstr = NSLayoutConstraint(item:signInButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44)
        
        NSLayoutConstraint.activate([vertConstr, widthConstr, heightConstr])
        
        keepView(signInButton, onPages: (0...introHeadings.count-1).map{CGFloat($0)})
    }
    
    private func configureHeadingViews() {
        for (index, heading) in introHeadings.enumerated() {
            let subheadingLabel = createSubheadingLabel(subheading: heading.subheading)
            let headerLabel = createHeaderLabel(header: heading.header)
            
            contentView.addSubview(subheadingLabel)
            contentView.addSubview(headerLabel)
            
            let subheadingVertConstr = NSLayoutConstraint(item: subheadingLabel, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -124)
            let subheadingWidthConstr = NSLayoutConstraint(item:subheadingLabel, attribute: .width, relatedBy: .equal, toItem: scrollView.superview, attribute: .width, multiplier: 0.8, constant: 0)
            let headerVertConstr = NSLayoutConstraint(item: headerLabel, attribute: .bottom, relatedBy: .equal, toItem: subheadingLabel, attribute: .top, multiplier: 1, constant: -5)            
            let headerWidthConstr = NSLayoutConstraint(item:headerLabel, attribute: .width, relatedBy: .equal, toItem: scrollView.superview, attribute: .width, multiplier: 0.8, constant: 0)
            
            NSLayoutConstraint.activate([subheadingVertConstr, subheadingWidthConstr, headerVertConstr, headerWidthConstr])
            
            keepView(headerLabel, onPage: CGFloat(index))
            keepView(subheadingLabel, onPage: CGFloat(index))
        }
    }
    
    private func createHeaderLabel(header: String) -> UILabel {
        let label = UILabel()
        label.text = header
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowOpacity = 0.7
        label.layer.shadowRadius = 3
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.left
        
        return label
    }
    
    private func createSubheadingLabel(subheading: String) -> UILabel {
        let label = UILabel()
        label.text = subheading
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        label.layer.opacity = 0.8
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowOpacity = 0.7
        label.layer.shadowRadius = 3
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.left
        
        return label
    }
    
    private func configureIntroVideoPlayerView(){        
        let introVideoPlayerViewController = IntroVideoPlayerViewController()
        addChildViewController(introVideoPlayerViewController)
        scrollView.superview?.insertSubview(introVideoPlayerViewController.view, belowSubview: scrollView)
        introVideoPlayerViewController.view.frame = scrollView.superview!.frame
    }
    
    func signInButtonTapped(_ sender: AnyObject) {
        Digits.sharedInstance().authenticate(with: self, configuration: digitsAuthenticationConfig){ session, error in
            if let userDigitsId = session?.userID {
                Crashlytics.sharedInstance().setUserIdentifier(userDigitsId)
                
                Answers.logLogin(withMethod: "Digits", success: true,
                                 customAttributes: ["User Id": userDigitsId])
            } else {
                print("Error: " + (error?.localizedDescription)!)
                
                Answers.logLogin(withMethod: "Digits", success: false,
                                 customAttributes: ["Error": error?.localizedDescription ?? "unknown error"])
            }
        }
    }
}
