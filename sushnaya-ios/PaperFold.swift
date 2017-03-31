//
//  FoldableNavigationController.swift
//  Food
//
//  Created by Igor Kurylenko on 3/30/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import PaperFold
import UIKit

class PaperFoldTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    static let NarrowSideControllerWidth = CGFloat(128)
    
    private lazy var foldableControllers: [FoldableNavigationController] = []
    
    convenience init(s: String) {
        self.init()
        
        delegate = self
    }
    
    func addChildViewController(_ childController: UIViewController, fullSideController: UIViewController?, narrowSideController: UIViewController? = nil) {
        self.addChildViewController(childController, narrowSideController: narrowSideController, fullSideController: fullSideController)
    }
    
    func addChildViewController(_ childController: UIViewController, narrowSideController: UIViewController?, fullSideController: UIViewController? = nil) {
        if let narrowSideController = narrowSideController,
            let fullSideController = fullSideController {
            
            let narrowFNC = FoldableNavigationController(rootViewController: childController)
            narrowFNC.setLeftViewController(leftViewController: narrowSideController, width: PaperFoldTabBarController.NarrowSideControllerWidth)
            foldableControllers.append(narrowFNC)
            
            let fullFNC = FoldableNavigationController(rootViewController: narrowFNC)
            fullFNC.setLeftViewController(leftViewController: fullSideController)
            fullFNC.tabBarItem.title = childController.tabBarItem.title
            foldableControllers.append(fullFNC)
            
            self.addChildViewController(fullFNC)
        
        } else if let narrowSideController = narrowSideController {
            let narrowFNC = FoldableNavigationController(rootViewController: childController)
            narrowFNC.setLeftViewController(leftViewController: narrowSideController, width: PaperFoldTabBarController.NarrowSideControllerWidth)
            narrowFNC.tabBarItem.title = childController.tabBarItem.title
            foldableControllers.append(narrowFNC)
            
            self.addChildViewController(narrowFNC)
        
        } else if let fullSideController = fullSideController {
            let fullFNC = FoldableNavigationController(rootViewController: childController)
            fullFNC.setLeftViewController(leftViewController: fullSideController)
            fullFNC.tabBarItem.title = childController.tabBarItem.title
            foldableControllers.append(fullFNC)
            
            self.addChildViewController(fullFNC)
        
        } else {
            self.addChildViewController(childController)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        foldableControllers.forEach{ $0.isFolded = true }
    }    
}

class FoldableNavigationController: UIViewController, PaperFoldViewDelegate {
    private var paperFoldView: PaperFoldView!
    private var rootViewController: UIViewController!
    private var leftViewController: UIViewController?

    var isFolded: Bool = true {
        didSet {
            if isFolded {
                self.paperFoldView.setPaperFoldState(PaperFoldStateDefault)
                
            } else {
                self.paperFoldView.setPaperFoldState(PaperFoldStateLeftUnfolded)
            }
        }
    }
    
    convenience init(rootViewController: UIViewController) {
        self.init()
        
        self.view.autoresizesSubviews = true
        
        paperFoldView = PaperFoldView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        self.view.addSubview(paperFoldView)
        paperFoldView.delegate = self
        paperFoldView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.rootViewController = rootViewController
        self.rootViewController.view.frame = CGRect(origin: CGPoint.zero, size: self.view.bounds.size)
        self.rootViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        paperFoldView.setCenterContent(rootViewController.view)
    }
    
    func setLeftViewController(leftViewController: UIViewController) {
        setLeftViewController(leftViewController: leftViewController, width: self.view.bounds.size.width)
    }
    
    func setLeftViewController(leftViewController: UIViewController, width: CGFloat) {
        leftViewController.view.frame = CGRect(x: 0, y: 0, width: width, height: self.view.bounds.size.height)
        
        let foldCount:Int32 = width > self.view.bounds.size.width / Constants.GoldenRatio ? 2: 1
        paperFoldView.setLeftFoldContent(leftViewController.view, foldCount: foldCount, pullFactor: 0.9)
        
        self.leftViewController = leftViewController
    }
    
    func paperFoldView(_ paperFoldView: Any!, didFoldAutomatically automated: Bool, to paperFoldState: PaperFoldState) {
        switch paperFoldState {
            
        case PaperFoldStateDefault:
            leftViewController?.viewWillDisappear(true)
            leftViewController?.viewDidDisappear(true)
            
            rootViewController.viewWillAppear(true)
            rootViewController.viewDidAppear(true)
        
        case PaperFoldStateLeftUnfolded:
            rootViewController.viewWillDisappear(true)
            rootViewController.viewDidDisappear(true)
            
            leftViewController?.viewWillAppear(true)
            leftViewController?.viewDidAppear(true)                        
        
        default:
            return
        }
    }
}
