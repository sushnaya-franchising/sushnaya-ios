import Foundation
import AsyncDisplayKit

protocol ProductsMosaicCollectionViewLayoutDelegate: ASCollectionDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: ProductsMosaicCollectionViewLayout, originalImageSizeAtIndexPath: IndexPath) -> CGSize
    
    func collectionView(_ collectionView: UICollectionView, layout: ProductsMosaicCollectionViewLayout, heightForTitleAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat
    
    func collectionView(_ collectionView: UICollectionView, layout: ProductsMosaicCollectionViewLayout, heightForSubtitleAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat?
    
    func collectionView(_ collectionView: UICollectionView, layout: ProductsMosaicCollectionViewLayout, heightForPricingAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat
}

class ProductsMosaicCollectionViewLayout: UICollectionViewFlowLayout {
    var numberOfColumns: Int
    var columnSpacing: CGFloat
    var _sectionInset: UIEdgeInsets
    var interItemSpacing: UIEdgeInsets
    var headerHeight: CGFloat
    var _columnHeights: [[CGFloat]]?
    var _itemAttributes = [[UICollectionViewLayoutAttributes]]()
    var _headerAttributes = [UICollectionViewLayoutAttributes]()
    var _allAttributes = [UICollectionViewLayoutAttributes]()
    
    required override init() {
        self.numberOfColumns = 2
        self.columnSpacing = 10.0
        self.headerHeight = 44.0 //viewcontroller
        self._sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
        self.interItemSpacing = UIEdgeInsetsMake(10.0, 0, 10.0, 0)
        super.init()
        self.scrollDirection = .vertical
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var delegate : ProductsMosaicCollectionViewLayoutDelegate?
    
    override func prepare() {
        super.prepare()
        guard let collectionView = self.collectionView else { return }
        
        _itemAttributes = []
        _allAttributes = []
        _headerAttributes = []
        _columnHeights = []
        
        var top: CGFloat = 0
        
        let numberOfSections: NSInteger = collectionView.numberOfSections
        
        for section in 0 ..< numberOfSections {
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            
            top += _sectionInset.top
            
            if (headerHeight > 0) {
                let headerSize: CGSize = self._headerSizeForSection(section: section)
                
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: NSIndexPath(row: 0, section: section) as IndexPath)
                
                attributes.frame = CGRect(x: _sectionInset.left, y: top, width: headerSize.width, height: headerSize.height)
                _headerAttributes.append(attributes)
                _allAttributes.append(attributes)
                top = attributes.frame.maxY
            }
            
            _columnHeights?.append([]) //Adding new Section
            for _ in 0 ..< self.numberOfColumns {
                self._columnHeights?[section].append(top)
            }
            
            let columnWidth = self._columnWidthForSection(section: section)
            _itemAttributes.append([])
            for idx in 0 ..< numberOfItems {
                let columnIndex: Int = self._shortestColumnIndexInSection(section: section)
                let indexPath = IndexPath(item: idx, section: section)
                
                let itemSize = self._itemSizeAtIndexPath(indexPath: indexPath);
                let xOffset = _sectionInset.left + (columnWidth + columnSpacing) * CGFloat(columnIndex)
                let yOffset = _columnHeights![section][columnIndex]
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height)
                
                _columnHeights?[section][columnIndex] = attributes.frame.maxY + interItemSpacing.bottom
                
                _itemAttributes[section].append(attributes)
                _allAttributes.append(attributes)
            }
            
            let columnIndex: Int = self._tallestColumnIndexInSection(section: section)
            top = (_columnHeights?[section][columnIndex])! - interItemSpacing.bottom + _sectionInset.bottom
            
            for idx in 0 ..< _columnHeights![section].count {
                _columnHeights![section][idx] = top
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var includedAttributes: [UICollectionViewLayoutAttributes] = []
        // Slow search for small batches
        for attribute in _allAttributes {
            if (attribute.frame.intersects(rect)) {
                includedAttributes.append(attribute)
            }
        }
        return includedAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.section < _itemAttributes.count,
            indexPath.item < _itemAttributes[indexPath.section].count
            else {
                return nil
        }
        return _itemAttributes[indexPath.section][indexPath.item]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if (elementKind == UICollectionElementKindSectionHeader) {
            return _headerAttributes[indexPath.section]
        }
        return nil
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if (!(self.collectionView?.bounds.size.equalTo(newBounds.size))!) {
            return true;
        }
        return false;
    }
    
    func _widthForSection (section: Int) -> CGFloat {
        return self.collectionView!.bounds.size.width - _sectionInset.left - _sectionInset.right;
    }
    
    func _columnWidthForSection(section: Int) -> CGFloat {
        return (self._widthForSection(section: section) - ((CGFloat(numberOfColumns - 1)) * columnSpacing)) / CGFloat(numberOfColumns)
    }
    
    func _itemSizeAtIndexPath(indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: self._columnWidthForSection(section: indexPath.section), height: 0)
        let originalSize = self.delegate!.collectionView(self.collectionView!, layout:self, originalImageSizeAtIndexPath:indexPath)
        if (originalSize.height > 0 && originalSize.width > 0) {
            size.height = originalSize.height / originalSize.width * size.width
        }
        
        size.height += self.delegate!.collectionView(self.collectionView!, layout: self, heightForTitleAtIndexPath: indexPath, width: size.width)
        
        if let subtitleHeight = self.delegate!.collectionView(self.collectionView!, layout: self, heightForSubtitleAtIndexPath: indexPath, width: size.width) {
            size.height += subtitleHeight
        }
        
        size.height += self.delegate!.collectionView(self.collectionView!, layout: self, heightForPricingAtIndexPath: indexPath, width: size.width)
        
        return size
    }
    
    func _headerSizeForSection(section: Int) -> CGSize {
        return CGSize(width: self._widthForSection(section: section), height: headerHeight)
    }
    
    override var collectionViewContentSize: CGSize {
        var height: CGFloat = 0
        if ((_columnHeights?.count)! > 0) {
            if (_columnHeights?[(_columnHeights?.count)!-1].count)! > 0 {
                height = (_columnHeights?[(_columnHeights?.count)!-1][0])!
            }
        }
        return CGSize(width: self.collectionView!.bounds.size.width, height: height)
    }
    
    func _tallestColumnIndexInSection(section: Int) -> Int {
        var index: Int = 0;
        var tallestHeight: CGFloat = 0;
        _ = _columnHeights?[section].enumerated().map { (idx,height) in
            if (height > tallestHeight) {
                index = idx;
                tallestHeight = height
            }
        }
        return index
    }
    
    func _shortestColumnIndexInSection(section: Int) -> Int {
        var index: Int = 0;
        var shortestHeight: CGFloat = CGFloat.greatestFiniteMagnitude
        _ = _columnHeights?[section].enumerated().map { (idx,height) in
            if (height < shortestHeight) {
                index = idx;
                shortestHeight = height
            }
        }
        return index
    }
    
}

class MosaicCollectionViewLayoutInspector: NSObject, ASCollectionViewLayoutInspecting {
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        let layout = collectionView.collectionViewLayout as! ProductsMosaicCollectionViewLayout
        return ASSizeRangeMake(CGSize.zero, layout._itemSizeAtIndexPath(indexPath: indexPath))
    }
    
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForSupplementaryNodeOfKind: String, at atIndexPath: IndexPath) -> ASSizeRange {
        let layout = collectionView.collectionViewLayout as! ProductsMosaicCollectionViewLayout
        return ASSizeRange.init(min: CGSize.zero, max: layout._headerSizeForSection(section: atIndexPath.section))
    }
    
    /**
     * Asks the inspector for the number of supplementary sections in the collection view for the given kind.
     */
    func collectionView(_ collectionView: ASCollectionView, numberOfSectionsForSupplementaryNodeOfKind kind: String) -> UInt {
        if (kind == UICollectionElementKindSectionHeader) {
            return UInt((collectionView.dataSource?.numberOfSections!(in: collectionView))!)
        } else {
            return 0
        }
    }
    
    /**
     * Asks the inspector for the number of supplementary views for the given kind in the specified section.
     */
    func collectionView(_ collectionView: ASCollectionView, supplementaryNodesOfKind kind: String, inSection section: UInt) -> UInt {
        if (kind == UICollectionElementKindSectionHeader) {
            return 1
        } else {
            return 0
        }
    }
    
    func scrollableDirections() -> ASScrollDirection {
        return ASScrollDirectionVerticalDirections;
    }
}

//protocol ProductsMosaicLayoutDelegate: ASCollectionDelegate {
//    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath,
//                        withWidth width: CGFloat) -> CGFloat
//    
//    func collectionView(_ collectionView: UICollectionView, heightForTitleAtIndexPath indexPath: IndexPath,
//                        withWidth width: CGFloat) -> CGFloat
//    
//    func collectionView(_ collectionView: UICollectionView, heightForSubtitleAtIndexPath indexPath: IndexPath,
//                        withWidth width: CGFloat) -> CGFloat
//    
//    func collectionView(_ collectionView: UICollectionView, heightForPricingAtIndexPath indexPath: IndexPath,
//                        withWidth width: CGFloat) -> CGFloat
//}
//
//class ProductsMosaicLayout: UICollectionViewFlowLayout {
//    weak var delegate: ProductsMosaicLayoutDelegate!
//    
//    var numberOfColumns = 2
//    var cellPadding: CGFloat = 0
//    fileprivate var cache = [UICollectionViewLayoutAttributes]()
//    fileprivate var contentHeight: CGFloat = 0.0
//    fileprivate var contentInsetLeft: CGFloat = 10
//    fileprivate var contentInsetRight: CGFloat = 10
//    
//    fileprivate var contentWidth: CGFloat {
//        guard let collectionView = collectionView else {
//            return 0
//        }
//        
//        return collectionView.bounds.width - (contentInsetLeft + contentInsetRight)
//    }
//    
//    override func prepare() {
//        super.prepare()
//        
//        guard cache.isEmpty else {
//            return
//        }
//        
//        guard let collectionView = collectionView else {
//            return
//        }
//        
//        guard let dataSource = collectionView.dataSource else {
//            return
//        }
//        
//        guard dataSource.numberOfSections!(in: collectionView) > 0 else {
//            return
//        }
//        
//        let columnWidth = contentWidth / CGFloat(numberOfColumns)
//        var xOffsets = [CGFloat]()
//        for column in 0..<numberOfColumns {
//            xOffsets.append(CGFloat(column) * columnWidth + contentInsetLeft)
//        }
//        
//        var columnIdx = 0
//        var yOffsets = [CGFloat](repeating: 0, count: numberOfColumns)
//        let width = columnWidth - cellPadding * 2
//        
//        for idx in 0..<dataSource.collectionView(collectionView, numberOfItemsInSection: 0) {
//            let indexPath = IndexPath(item: idx, section: 0)
//            
//            let photoHeight = delegate.collectionView(collectionView,
//                                                      heightForImageAtIndexPath: indexPath, withWidth: width)
//            let titleHeight = delegate.collectionView(collectionView,
//                                                      heightForTitleAtIndexPath: indexPath, withWidth: width)
//            let subtitleHeight = delegate.collectionView(collectionView,
//                                                         heightForSubtitleAtIndexPath: indexPath, withWidth: width)
//            let priceHeight = delegate.collectionView(collectionView,
//                    heightForPricingAtIndexPath: indexPath, withWidth: width)
//
//            let height = photoHeight + titleHeight + subtitleHeight + priceHeight
//            let frame = CGRect(x: xOffsets[columnIdx], y: yOffsets[columnIdx], width: columnWidth, height: height)
//            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
//            
//            
//            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//            attributes.frame = insetFrame
//            cache.append(attributes)
//            
//            contentHeight = max(contentHeight, insetFrame.maxY)
//            yOffsets[columnIdx] = yOffsets[columnIdx] + insetFrame.height
//
//            columnIdx = getShortestColumnIdx(yOffsets)
//        }
//    }
//
//    private func getShortestColumnIdx(_ yOffsets: [CGFloat]) -> Int {
//        var result = 0
//        var shortestYOffset = CGFloat.greatestFiniteMagnitude
//        _ = yOffsets.enumerated().map { (idx, yOffset) in
//            if yOffset < shortestYOffset {
//                result = idx
//                shortestYOffset = yOffset
//            }
//        }
//
//        return result
//    }
//    
//    override var collectionViewContentSize: CGSize {
//        return CGSize(width: contentWidth, height: contentHeight)
//    }
//    
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        return cache.filter{ $0.frame.intersects(rect) }
//    }
//}
