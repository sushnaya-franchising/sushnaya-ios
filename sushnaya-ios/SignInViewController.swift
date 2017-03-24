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
import AVKit
import AVFoundation
import FontAwesome_swift


class SignInViewController: AnimatedPagingScrollViewController {
    private let introHeadings = [
        (header: "Добро пожаловать в Сушную!", subheading: "Здесь лучшие роллы по самой низкой цене"),
        (header: "Более 300 видов блюд", subheading: "70 видов роллов, 30 видов пиццы"),
        (header: "Бесплатная доставка", subheading: "При заказе от 600₽")
    ]
    
    
    @IBOutlet weak var signInButton: UIButton!    
    @IBOutlet weak var pageControl: UIPageControl!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func numberOfPages() -> Int {
        return introHeadings.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavbar()
        
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavbar()
    }
    
    private func configureNavbar() {
        let backIcon = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: UIColor.black, size: CGSize(width: 18, height: 18))
        navigationController?.navigationBar.backIndicatorImage = backIcon
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backIcon
        navigationItem.title = ""
        
        hideNavbar()
    }
    
    private func hideNavbar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func configureViews() {
        configureIntroVideoPlayerView()
        
        configureHeadingViews()
        
        configureSignInButton()
        
        configurePageControl()
        
        animateCurrentFrame() // tackles RazzleDazzle bug
    }
    
    private func configurePageControl() {
        guard introHeadings.count > 1 else {return}
        
        scrollView.superview?.addSubview(pageControl)
        
        pageControl.numberOfPages = introHeadings.count
        pageControl.currentPage = 0
    }
    
    @IBAction func onPageControlValueChanged(_ sender: Any) {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    private func configureSignInButton() {
        scrollView.superview?.addSubview(signInButton)
        
        configureSignInButtonTitle(signInButton)
    }
    
    private func configureSignInButtonTitle(_ signInButton: UIButton) {
        let curSignInButtonText = "Войти "
        let buttonString = curSignInButtonText + String.fontAwesomeIcon(name: .chevronRight)
        let buttonStringAttributed = NSMutableAttributedString(string: buttonString, attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 17)])
        buttonStringAttributed.addAttribute(NSFontAttributeName, value: UIFont.fontAwesome(ofSize: 14), range: NSRange(location: curSignInButtonText.characters.count, length: 1))
        buttonStringAttributed.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, buttonString.characters.count))
        
        signInButton.setAttributedTitle(buttonStringAttributed, for: .normal)
        
        signInButton.titleLabel?.layer.shadowOffset = CGSize(width: 0, height: 0)
        signInButton.titleLabel?.layer.shadowOpacity = 0.7
        signInButton.titleLabel?.layer.shadowRadius = 3
    }
    
    private func configureHeadingViews() {
        for (index, heading) in introHeadings.enumerated() {
            let subheadingLabel = createSubheadingLabel(subheading: heading.subheading)
            let headerLabel = createHeaderLabel(header: heading.header)
            
            contentView.addSubview(subheadingLabel)
            contentView.addSubview(headerLabel)
            
            keepSubheadingLabel(subheadingLabel: subheadingLabel, onPage: CGFloat(index))
            keepHeaderLabel(headerLabel: headerLabel, subheadingLabel: subheadingLabel, onPage: CGFloat(index))
        }
    }
    
    private func keepSubheadingLabel(subheadingLabel: UILabel, onPage page: CGFloat) {
        let vertConstr = NSLayoutConstraint(item: subheadingLabel, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -124)
        let widthConstr = NSLayoutConstraint(item:subheadingLabel, attribute: .width, relatedBy: .equal, toItem: scrollView.superview, attribute: .width, multiplier: 0.8, constant: 0)
        
        NSLayoutConstraint.activate([vertConstr, widthConstr])
        
        keepView(subheadingLabel, onPage: page)
    }
    
    private func keepHeaderLabel(headerLabel: UILabel, subheadingLabel: UILabel, onPage page: CGFloat) {
        let vertConstr = NSLayoutConstraint(item: headerLabel, attribute: .bottom, relatedBy: .equal, toItem: subheadingLabel, attribute: .top, multiplier: 1, constant: -5)
        let widthConstr = NSLayoutConstraint(item:headerLabel, attribute: .width, relatedBy: .equal, toItem: scrollView.superview, attribute: .width, multiplier: 0.8, constant: 0)
    
        NSLayoutConstraint.activate([vertConstr, widthConstr])
    
        keepView(headerLabel, onPage: page)
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
    
    private func configureIntroVideoPlayerView() {
        let introVideoPlayerViewController = IntroVideoPlayerViewController()
        addChildViewController(introVideoPlayerViewController)
        scrollView.superview?.insertSubview(introVideoPlayerViewController.view, belowSubview: scrollView)
        introVideoPlayerViewController.view.frame = scrollView.superview!.frame
    }        
}
