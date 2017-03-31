//
//  SignInNode.swift
//  Food
//
//  Created by Igor Kurylenko on 3/28/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import FontAwesome_swift
import pop

class SignInNode: ASDisplayNode {
    
    let introVideoNode = ASVideoNode()
    let signInPagerNode = SignInPagerNode()
    let signInButtonNode = ButtonNode()
    
    override required init() {
        super.init()
        
        automaticallyManagesSubnodes = true
        
        initIntroVideoNode()
        
        initSignInButtonNode()
        // todo: sign in button click animation
    }
        
    private func initIntroVideoNode() {
        guard let path = Bundle.main.path(forResource: "intro_video", ofType: "mp4") else {
            debugPrint("intro_video.mp4 not found")
            return
        }
        
        let asset = AVAsset(url: URL(fileURLWithPath: path))
        introVideoNode.asset = asset
        introVideoNode.gravity = AVLayerVideoGravityResizeAspectFill
        introVideoNode.shouldAutoplay = true
        introVideoNode.shouldAutorepeat = true
        introVideoNode.muted = true
        introVideoNode.isEnabled = false
    }
    
    private func initSignInButtonNode() {
        let signInButtonText = "Войти "
        let buttonString = signInButtonText + String.fontAwesomeIcon(name: .chevronRight)
        let buttonStringAttributed = NSMutableAttributedString(string: buttonString, attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 17)])
        buttonStringAttributed.addAttribute(NSFontAttributeName, value: UIFont.fontAwesome(ofSize: 14), range: NSRange(location: signInButtonText.characters.count, length: 1))
        buttonStringAttributed.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, buttonString.characters.count))
        
        signInButtonNode.setAttributedTitle(buttonStringAttributed, for: .normal)
        
        signInButtonNode.titleNode.layer.shadowOffset = CGSize(width: 0, height: 0)
        signInButtonNode.titleNode.layer.shadowOpacity = 0.7
        signInButtonNode.titleNode.layer.shadowRadius = 3
    }        
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        signInButtonNode.style.height = ASDimensionMakeWithPoints(64.0)
        signInButtonNode.style.width = ASDimensionMakeWithFraction(1.0)
        
        let stack = ASStackLayoutSpec(direction: .vertical,
                                                spacing: 0,
                                                justifyContent: .end,
                                                alignItems: .center,
                                                children: [signInButtonNode])
        
        let background = ASBackgroundLayoutSpec(child: signInPagerNode, background: introVideoNode)
        
        return ASBackgroundLayoutSpec(child: stack, background: background)
    }
    
}
