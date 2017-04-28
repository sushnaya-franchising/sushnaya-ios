//
// Created by Igor Kurylenko on 4/3/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol ProductsMosaicLayoutDelegate: ASCollectionDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath,
                        withWidth width: CGFloat) -> CGFloat
    
    func collectionView(_ collectionView: UICollectionView, heightForTitleAtIndexPath indexPath: IndexPath,
                        withWidth width: CGFloat) -> CGFloat
    
    func collectionView(_ collectionView: UICollectionView, heightForSubtitleAtIndexPath indexPath: IndexPath,
                        withWidth width: CGFloat) -> CGFloat
    
    func collectionView(_ collectionView: UICollectionView, heightForPricingAtIndexPath indexPath: IndexPath,
                        withWidth width: CGFloat) -> CGFloat
}

class ProductsMosaicLayout: UICollectionViewFlowLayout {
    weak var delegate: ProductsMosaicLayoutDelegate!
    
    var numberOfColumns = 2
    var cellPadding: CGFloat = 0
    var _cache = [UICollectionViewLayoutAttributes]()
    var _contentHeight: CGFloat = 0.0
    var _contentInsetLeft: CGFloat = 10
    var _contentInsetRight: CGFloat = 10
    
    var _contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        
        return collectionView.bounds.width - (_contentInsetLeft + _contentInsetRight)
    }
    
    override func prepare() {
        super.prepare()
        
        guard _cache.isEmpty else {
            return
        }
        guard let collectionView = collectionView else {
            return
        }
        
        guard let dataSource = collectionView.dataSource else {
            return
        }
        
        let columnWidth = _contentWidth / CGFloat(numberOfColumns)
        var xOffsets = [CGFloat]()
        for column in 0..<numberOfColumns {
            xOffsets.append(CGFloat(column) * columnWidth + _contentInsetLeft)
        }
        
        var columnIdx = 0
        var yOffsets = [CGFloat](repeating: 0, count: numberOfColumns)
        let width = columnWidth - cellPadding * 2
        
        for idx in 0..<dataSource.collectionView(collectionView, numberOfItemsInSection: 0) {
            let indexPath = IndexPath(item: idx, section: 0)
            
            let photoHeight = delegate.collectionView(collectionView,
                                                      heightForPhotoAtIndexPath: indexPath, withWidth: width)
            let titleHeight = delegate.collectionView(collectionView,
                                                      heightForTitleAtIndexPath: indexPath, withWidth: width)
            let subtitleHeight = delegate.collectionView(collectionView,
                                                         heightForSubtitleAtIndexPath: indexPath, withWidth: width)
            let priceHeight = delegate.collectionView(collectionView,
                    heightForPricingAtIndexPath: indexPath, withWidth: width)

            let height = cellPadding + photoHeight + titleHeight + subtitleHeight + priceHeight + cellPadding
            let frame = CGRect(x: xOffsets[columnIdx], y: yOffsets[columnIdx], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            _cache.append(attributes)
            
            _contentHeight = max(_contentHeight, frame.maxY)
            yOffsets[columnIdx] = yOffsets[columnIdx] + height

            columnIdx = getShortestColumnIdx(yOffsets)
        }
    }

    private func getShortestColumnIdx(_ yOffsets: [CGFloat]) -> Int {
        var result = 0
        var shortestYOffset = CGFloat.greatestFiniteMagnitude
        _ = yOffsets.enumerated().map { (idx, yOffset) in
            if yOffset < shortestYOffset {
                result = idx
                shortestYOffset = yOffset
            }
        }

        return result
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: _contentWidth, height: _contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return _cache.filter{ $0.frame.intersects(rect) }
    }
}
