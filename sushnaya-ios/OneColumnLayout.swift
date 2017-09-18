//
// Created by Igor Kurylenko on 4/3/17.
// Copyright (c) 2017 igor kurilenko. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol OneColumnLayoutDelegate: ASCollectionDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath,
                        withWidth width: CGFloat) -> CGFloat

    func collectionView(_ collectionView: UICollectionView, heightForTitleAtIndexPath indexPath: IndexPath,
                        withWidth width: CGFloat) -> CGFloat
}

class OneColumnLayout: UICollectionViewFlowLayout {
    weak var delegate: OneColumnLayoutDelegate!

    var cellPadding: CGFloat = 0
    var _cache = [UICollectionViewLayoutAttributes]()
    var _contentHeight: CGFloat = 0.0
    var _contentInsetLeft: CGFloat = 0
    var _contentInsetRight: CGFloat = 0

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

        let columnWidth = _contentWidth
        let xOffset = _contentInsetLeft
        var yOffset: CGFloat = 0
        let width = columnWidth - cellPadding * 2

        for idx in 0..<dataSource.collectionView(collectionView, numberOfItemsInSection: 0) {
            let indexPath = IndexPath(item: idx, section: 0)

            let imageHeight = delegate.collectionView(collectionView,
                    heightForImageAtIndexPath: indexPath, withWidth: width)
            let titleHeight = delegate.collectionView(collectionView,
                    heightForTitleAtIndexPath: indexPath, withWidth: width)

            let height = cellPadding + imageHeight + titleHeight + cellPadding
            let frame = CGRect(x: xOffset, y: yOffset, width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            _cache.append(attributes)

            _contentHeight = max(_contentHeight, frame.maxY)
            yOffset = yOffset + height
        }
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: _contentWidth, height: _contentHeight)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return _cache.filter {
            $0.frame.intersects(rect)
        }
    }
}
