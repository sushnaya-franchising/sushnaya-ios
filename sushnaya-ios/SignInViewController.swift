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


class SignInViewController: AnimatedPagingScrollViewController {
    
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
    
    
    private let firstLabel = UILabel()
    private let secondLabel = UILabel()
    private let thirdLabel = UILabel()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func numberOfPages() -> Int {
        return 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    private func configureViews() {
        let signInButton = UIButton(type: .roundedRect)
        signInButton.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
        signInButton.setTitle("Войти", for: [])
        signInButton.addTarget(self, action: #selector(self.signInButtonTapped(_:)), for: .touchUpInside)
        
        firstLabel.text = "Про продукцию"
        secondLabel.text = "Про условия бесплатной доставки"
        thirdLabel.text = "Как добавить в корзину"
        
        contentView.addSubview(signInButton)
        contentView.addSubview(firstLabel)
        contentView.addSubview(secondLabel)
        contentView.addSubview(thirdLabel)
        
        NSLayoutConstraint(item: bottomLayoutGuide, attribute: .top, relatedBy: .equal, toItem: signInButton, attribute: .bottom, multiplier: 1, constant: 20).isActive=true
        contentView.addConstraint(NSLayoutConstraint(item: firstLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: secondLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: thirdLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        
        keepView(signInButton, onPages: [0,1,2])
        keepView(firstLabel, onPage: 0)
        keepView(secondLabel, onPage: 1)
        keepView(thirdLabel, onPage: 2)
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
