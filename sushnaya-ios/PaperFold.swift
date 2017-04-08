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

protocol PaperFoldAsyncView {
    var onViewUpdated: (() -> ())? { get set }
}

class PaperFoldNavigationController: ASNavigationController, PaperFoldViewDelegate {
    private var paperFoldView: PaperFoldView!
    private var rootViewController: UIViewController!
    private var leftViewController: UIViewController?
    private var updateScreenShotDelayed: Debouncer!


    func setPaperFoldState(isFolded: Bool, animated: Bool) {
        if isFolded {
            self.paperFoldView.setPaperFoldState(PaperFoldStateDefault, animated: animated)

        } else {
            self.paperFoldView.setPaperFoldState(PaperFoldStateLeftUnfolded, animated: animated)
        }
    }

    convenience override init(rootViewController: UIViewController) {
        self.init()

        // todo: fix PaperFold MultiFoldView to retake screenshot before open
        updateScreenShotDelayed = debounce(delay: 1) { [unowned self] in
            if self.paperFoldView.state == PaperFoldStateDefault {
                self.paperFoldView.leftFoldView.contentViewHolder.isHidden = false
                self.paperFoldView.leftFoldView.drawScreenshotOnFolds()
                self.paperFoldView.leftFoldView.contentViewHolder.isHidden = true
            }
        }

        self.view.autoresizesSubviews = true

        paperFoldView = PaperFoldView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        paperFoldView.useOptimizedScreenshot = false

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

        let foldCount: Int32 = width > self.view.bounds.size.width / Constants.GoldenRatio ? 2 : 1
        paperFoldView.setLeftFoldContent(leftViewController.view, foldCount: foldCount, pullFactor: 0.9)

        self.leftViewController = leftViewController
    }

    func retakeScreenShot() {
        // DIRTY HACK TO TACKLE ASYNC DISPLAYING. Retake screenshot after some period of time.
        updateScreenShotDelayed.apply()
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
