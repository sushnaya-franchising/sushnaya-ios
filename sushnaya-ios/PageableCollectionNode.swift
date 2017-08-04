//
//  CollectionWithCustomPagingNode.swift
//  sushnaya-ios
//
//  Created by Igor Kurylenko on 7/27/17.
//  Copyright © 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop

@objc protocol PageableCollectionDelegate: class {
    @objc optional var pageWidth:CGFloat { get }
    @objc optional func pageableCollectionNode(_ node: PageableCollectionNode, willTurnPage page: Int, velocity: CGPoint)
    @objc optional func pageableCollectionNode(_ node: PageableCollectionNode, didTurnPage page: Int)
    @objc optional func pageableCollectionNodeDidScroll(_ scrollView: UIScrollView)
    @objc optional func pageableCollectionNode(_ node: PageableCollectionNode, didSelectPageAt indexPath: IndexPath)
}

protocol PageableCollectionDataSource: class {
    func pageableCollectionNode(_ node: PageableCollectionNode, numberOfPagesInSection section: Int) -> Int
    func pageableCollectionNode(_ node: PageableCollectionNode, nodeBlockForPageAt indexPath: IndexPath) -> ASCellNodeBlock
}


class PageableCollectionNode: ASDisplayNode {
    fileprivate let kMinVelocityToTurnThePage: CGFloat = 200
    fileprivate let kPagingAnimationKey = "PagingAnimation"
    
    private var collectionNode: ASCollectionNode
    weak var delegate: PageableCollectionDelegate?
    weak var dataSource: PageableCollectionDataSource?
    
    var currentPageNumber = 0
    
    var allowsSelection: Bool {
        set {
            collectionNode.allowsSelection = newValue
        }
        
        get {
            return collectionNode.allowsSelection
        }
    }
    
    var collectionView: UICollectionView {
        return collectionNode.view
    }
    
    init(collectionViewLayout: UICollectionViewFlowLayout) {
        self.collectionNode = ASCollectionNode(collectionViewLayout: collectionViewLayout)
        
        super.init()
        
        self.automaticallyManagesSubnodes = true
        
        setupNodes()
    }
    
    private func setupNodes() {
        setupCollectionNode()
    }
    
    private func setupCollectionNode() {
        collectionNode.delegate = self
        collectionNode.dataSource = self
        collectionNode.allowsSelection = true
    }
    
    func reloadData() {
        collectionNode.reloadData()
    }
    
    func pageForItem(at indexPath: IndexPath) -> ASCellNode? {
        return collectionNode.nodeForItem(at: indexPath)
    }
    
    override func didLoad() {
        super.didLoad()
        collectionView.isPagingEnabled = true
        collectionView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(PageableCollectionNode.didPanGesture(_:))))
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        collectionNode.style.preferredSize = constrainedSize.max
        
        return ASWrapperLayoutSpec(layoutElement: collectionNode)
    }
}

extension PageableCollectionNode: ASCollectionDataSource, ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return dataSource!.pageableCollectionNode(self, numberOfPagesInSection: section)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return dataSource!.pageableCollectionNode(self, nodeBlockForPageAt: indexPath)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        delegate?.pageableCollectionNode?(self, didSelectPageAt: indexPath)
    }        
}

extension PageableCollectionNode {
    var leftMostVisiblePageNumber: Int {
        return Int(floor(collectionView.contentOffset.x / pageWidth))
    }
    
    var pageNumberAfterLeftMostVisiblePage: Int {
        return Int(floor((collectionView.contentOffset.x + pageWidth) / pageWidth))
    }
    
    var pageWidth: CGFloat {
        return delegate?.pageWidth ?? frame.width
    }
    
    fileprivate var maxOffsetX:CGFloat {
        return collectionView.contentSize.width - pageWidth
    }
    
    
    func didPanGesture(_ recognizer: UIPanGestureRecognizer) {
        if collectionView.isPagingEnabled && maxOffsetX > 0 {
            switch recognizer.state {
            case .began:
                didBeginPanGesture(recognizer)
                
            case .changed:
                didChangePanGesture(recognizer)
                
            case .ended:
                didEndPanGesture(recognizer)
                
            default: break
            }
        }
    }
    
    fileprivate func didBeginPanGesture(_ recognizer: UIPanGestureRecognizer) {
        stopCompleteTranslationToClosestPage()
    }
    
    fileprivate func didChangePanGesture(_ recognizer: UIPanGestureRecognizer) {
        translate(recognizer)
        
        recognizer.setTranslation(CGPoint.zero, in: view)
    }
    
    fileprivate func didEndPanGesture(_ recognizer: UIPanGestureRecognizer) {
        completeTranslationToClosestPage(recognizer)
    }
    
    fileprivate func stopCompleteTranslationToClosestPage() {
        collectionView.pop_removeAllAnimations()
    }
    
    fileprivate func translate(_ recognizer: UIPanGestureRecognizer) {
        let translationX = getTranslationX(recognizer)
        
        collectionView.contentOffset.x -= translationX
        
        delegate?.pageableCollectionNodeDidScroll?(collectionView)
    }
    
    fileprivate func getTranslationX(_ recognizer: UIPanGestureRecognizer) -> CGFloat {
        let translation = recognizer.translation(in: collectionView)
        
        return (collectionView.contentOffset.x > maxOffsetX || collectionView.contentOffset.x < 0) ?
            translation.x / 3: translation.x
    }
    
    fileprivate func completeTranslationToClosestPage(_ recognizer: UIPanGestureRecognizer) {
        let velocity = getVelocity(recognizer)
        let closestPageOffsetX = getOffsetXToClosestPage(velocity)
        let closestPageNumber = pageWidth == 0 ? 0 : Int(closestPageOffsetX/pageWidth)
        var completionBlock: ((POPAnimation?, Bool)->Void)!
        
        if currentPageNumber != closestPageNumber {
            self.delegate?.pageableCollectionNode?(self, willTurnPage: currentPageNumber, velocity: velocity)
            
            completionBlock = { [unowned self] (_, finished) in
                if finished {
                    let didTurnPage = self.currentPageNumber
                    self.currentPageNumber = closestPageNumber
                    self.delegate?.pageableCollectionNode?(self, didTurnPage: didTurnPage)
                }
            }
        }
        
        playCompleteTranslationAnimation(closestPageOffsetX, velocity: velocity,
                                         completionBlock: completionBlock)
    }
    
    fileprivate func getPageNumber(_ offsetX: CGFloat) -> Int {
        return Int(offsetX/pageWidth)
    }
    
    fileprivate func getVelocity(_ recognizer: UIPanGestureRecognizer) -> CGPoint {
        var velocity = recognizer.velocity(in: collectionView)
        velocity.x = -velocity.x
        velocity.y = 0
        
        return velocity
    }
    
    fileprivate func getOffsetXToClosestPage(_ velocity: CGPoint) -> CGFloat {
        let f = abs(velocity.x) < kMinVelocityToTurnThePage ?
            roundf : velocity.x > 0 ? ceilf : floorf
        
        var offsetX = collectionView.contentOffset.x
        offsetX = pageWidth * f((offsetX/pageWidth).asFloat).asCGFloat
        offsetX = offsetX < 0 ? 0: offsetX
        offsetX = offsetX > maxOffsetX ? maxOffsetX: offsetX
        
        return offsetX
    }
    
    fileprivate func playCompleteTranslationAnimation(
        _ offsetX: CGFloat, velocity: CGPoint, completionBlock: ((POPAnimation?, Bool)->Void)! = nil) {
        let animation = createSoftContentOffsetAnimation(offsetX, velocity: velocity)
        animation.completionBlock = completionBlock
        
        collectionView.pop_add(animation, forKey: kPagingAnimationKey)
    }
    
    fileprivate func createSoftContentOffsetAnimation(_ offsetX: CGFloat, velocity: CGPoint) -> POPSpringAnimation {
        let animation = POPSpringAnimation.scrollViewContentOffset(
            toValue: (offsetX.asFloat, 0), velocity: velocity.asPoint)
        animation.dynamicsTension = 101.69
        animation.dynamicsFriction = 18.1
        
        return animation
    }
}
