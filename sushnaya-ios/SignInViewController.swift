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
    
    private var introVideoPlayer:IntroVideoPlayer!
    private var pageControl: UIPageControl?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func numberOfPages() -> Int {
        return introHeadings.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        introVideoPlayer.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        introVideoPlayer.pause()
    }
    
    private func configureViews() {
        configureIntroVideoPlayerView()
        
        configureHeadingViews()
        
        configureSignInButton()
        
        configurePageControl()
    }
    
    private func configurePageControl() {
        guard introHeadings.count > 1 else {return}
        
        pageControl = createPageControl()
        pageControl!.addTarget(self, action: #selector(SignInViewController.changePage(sender:)), for: UIControlEvents.valueChanged)
        
        contentView.addSubview(pageControl!)
        keepView(pageControl!, onPages: (0...introHeadings.count).map{CGFloat($0)})
        
        let vertConstr = NSLayoutConstraint(item: pageControl!, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -84)
        
        NSLayoutConstraint.activate([vertConstr])
    }
    
    private func createPageControl() -> UIPageControl {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = introHeadings.count
        pageControl.currentPage = 0
        
        return pageControl
    }
    
    func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl!.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl?.currentPage = Int(pageNumber)
    }
    
    private func configureSignInButton() {
        let button = createSignInButton()
        button.addTarget(self, action: #selector(SignInViewController.signInButtonTapped(_:)), for: .touchUpInside)
        
        contentView.addSubview(button)
        keepView(button, onPages: (0...introHeadings.count).map{CGFloat($0)})
        
        let vertConstr = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -20)
        
        let widthConstr = NSLayoutConstraint(item:button, attribute: .width, relatedBy: .equal, toItem: scrollView.superview, attribute: .width, multiplier: 0.8, constant: 0)
        
        let heightConstr = NSLayoutConstraint(item:button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44)
        
        NSLayoutConstraint.activate([vertConstr, widthConstr, heightConstr])
    }
    
    private func createSignInButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.titleLabel?.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.titleLabel?.layer.shadowOpacity = 0.7
        button.titleLabel?.layer.shadowRadius = 3
        button.layer.cornerRadius = 5;
//        button.layer.borderWidth = 2;
//        button.layer.borderColor = UIColor.white.cgColor
        
        return button
    }
    
    private func configureHeadingViews() {
        var i = 0
        for (header, subheading) in introHeadings {
            let subheadingLabel = createSubheadingLabel(subheading: subheading)
            let headerLabel = createHeaderLabel(header: header)
            
            contentView.addSubview(subheadingLabel)
            contentView.addSubview(headerLabel)
            
            let subheadingVertConstr = NSLayoutConstraint(item: subheadingLabel, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -124)
            
            let subheadingWidthConstr = NSLayoutConstraint(item:subheadingLabel, attribute: .width, relatedBy: .equal, toItem: scrollView.superview, attribute: .width, multiplier: 0.8, constant: 0)
            
            let headerVertConstr = NSLayoutConstraint(item: headerLabel, attribute: .bottom, relatedBy: .equal, toItem: subheadingLabel, attribute: .top, multiplier: 1, constant: -5)
            
            let headerWidthConstr = NSLayoutConstraint(item:headerLabel, attribute: .width, relatedBy: .equal, toItem: scrollView.superview, attribute: .width, multiplier: 0.8, constant: 0)
            
            
            NSLayoutConstraint.activate([subheadingVertConstr, subheadingWidthConstr, headerVertConstr, headerWidthConstr])
            
            keepView(headerLabel, onPage: CGFloat(i))
            keepView(subheadingLabel, onPage: CGFloat(i))
            
            i += 1
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
    
    // todo: make video to appear smoothly
    private func configureIntroVideoPlayerView(){
        introVideoPlayer = IntroVideoPlayer(forResource: "intro_video", ofType: "mp4")
        
        if let introVideoLayer = introVideoPlayer.layer,
            let parentLayer = scrollView.superview?.layer {
            introVideoLayer.frame = parentLayer.bounds
            parentLayer.insertSublayer(introVideoLayer, below: scrollView.layer)
        }
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
