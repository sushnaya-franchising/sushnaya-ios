//
//  ViewController.swift
//  Food
//
//  Created by Igor Kurylenko on 3/27/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class SignInViewController: ASViewController<SignInNode> {
    
    private var isStatusBarHidden: Bool = false
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.fade
    }
    
    init() {
        super.init(node: SignInNode())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        node.backgroundColor = UIColor.black
        setupSignInButton()
        setupNavbar()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavbar()
        
        isStatusBarHidden = false
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setStatusBarHidden(true)
    }
    
    private func setStatusBarHidden(_ hidden: Bool) {
        isStatusBarHidden = hidden
        
        UIView.animate(withDuration: 0.1) { () -> Void in
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    private func setupSignInButton() {
        self.node.signInButtonNode.addTarget(self, action: #selector(SignInViewController.signInButtonTapped), forControlEvents: .touchUpInside)
    }
    
    private func setupNavbar() {
        let backIcon = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: UIColor.black, size: CGSize(width: 18, height: 18))
        navigationController?.navigationBar.backIndicatorImage = backIcon
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backIcon        
        navigationItem.title = EmptyString
        
        hideNavbar()
    }
    
    private func hideNavbar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func signInButtonTapped() {
        setStatusBarHidden(false)
        
        let phoneNumberVC = PhoneNumberViewController()
        navigationController?.pushViewController(phoneNumberVC, animated: true)
    }
}

