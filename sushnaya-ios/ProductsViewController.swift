import Foundation
import AsyncDisplayKit
import FontAwesome_swift
import pop
import PaperFold
import CoreStore


class ProductsViewController: ASViewController<ASDisplayNode> {

    let cellInsets = Constants.ProductCellLayout.CellInsets
    let titleLabelInsets = Constants.ProductCellLayout.TitleLabelInsets
    let subtitleLabelInsets = Constants.ProductCellLayout.SubtitleLabelInsets
    let pricingInsets = Constants.ProductCellLayout.PricingInsets
    let modifierInsets = Constants.ProductCellLayout.ModifierTextInsets
    let priceButtonInsets = Constants.ProductCellLayout.PriceButtonInsets
    let priceButtonContentInsets = Constants.ProductCellLayout.PriceButtonContentInsets
    let titleStringAttrs = Constants.ProductCellLayout.TitleStringAttributes
    let subtitleStringAttrs = Constants.ProductCellLayout.SubtitleStringAttributes
    let priceStringAttrs = Constants.ProductCellLayout.PriceStringAttributes
    let priceWithModifierStringAttrs = Constants.ProductCellLayout.PriceWithModifierStringAttributes
    let modifierStringAttrs = Constants.ProductCellLayout.PriceModifierStringAttributes

    fileprivate var headerTextCellNode: ASTextCellNode!
    fileprivate var collectionNode: ASCollectionNode!
    fileprivate let layoutInspector = MosaicCollectionViewLayoutInspector()
    fileprivate var selectedProductIndexPath: IndexPath?

    var products: ListMonitor<ProductEntity> {
        return app.core.products
    }


    var categoryName = App.brandName {
        didSet {
            headerTextCellNode.text = categoryName
        }
    }

    convenience init() {
        self.init(node: ASDisplayNode())

        setupHeaderTextCellNode()
        setupCollectionNode()

        self.node.automaticallyManagesSubnodes = true
        self.node.backgroundColor = PaperColor.White
        self.node.layoutSpecBlock = { [unowned self] _ in
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0), child: self.collectionNode)
        }

        products.addObserver(self)
    }

    private func setupHeaderTextCellNode() {
        let textAttributes: NSDictionary = [
            NSForegroundColorAttributeName: PaperColor.Gray800,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 19)
        ]
        let textInsets = UIEdgeInsets(top: 11, left: 0, bottom: 11, right: 0)
        headerTextCellNode = ASTextCellNode(attributes: textAttributes as! [AnyHashable: Any], insets: textInsets)
        headerTextCellNode.text = categoryName
    }

    private func setupCollectionNode() {
        let layout = ProductsMosaicCollectionViewLayout()
        layout.numberOfColumns = 2;
        layout.headerHeight = 44;
        layout.delegate = self

        collectionNode = ASCollectionNode(frame: CGRect.zero, collectionViewLayout: layout)
        collectionNode.delegate = self
        collectionNode.dataSource = self
        collectionNode.layoutInspector = layoutInspector
        collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
    }

    deinit {
        EventBus.unregister(self)
        products.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionNode.view.isScrollEnabled = true
        collectionNode.view.showsVerticalScrollIndicator = false

        EventBus.onMainThread(self, name: DidSelectCategoryEvent.name) { [unowned self] notification in
            if let category = (notification.object as! DidSelectCategoryEvent).category {
                self.categoryName = category.name
            }
            
            self.scrollToTop()
        }

        EventBus.onMainThread(self, name: DidSelectRecommendationsEvent.name) { _ in
            self.categoryName = App.brandName
            
            self.scrollToTop()
        }        
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        collectionNode.view.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 49 + 16, right: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)

        FoodServiceRest.requestMenus(authToken: app.authToken!) // sync menus        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    fileprivate func scrollToTop() {
        collectionNode.view.setContentOffset(CGPoint.zero, animated: true)
    }
    
    fileprivate func setCollectionEnabled(_ enabled: Bool) {
        UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .beginFromCurrentState,
                animations: { () -> Void in
                    self.collectionNode.alpha = enabled ? 1.0 : 0.5
                    self.collectionNode.isUserInteractionEnabled = enabled
                },
                completion: nil
        )
    }
}

extension ProductsViewController: ProductCellNodeDelegate {
    func productCellNode(_ node: ProductCellNode, didSelectProduct product: ProductEntity, withPrice price: PriceEntity) {
        AddToCartEvent.fire(product: product.plain, withPrice: price.plain)
    }
}

extension ProductsViewController: ASCollectionDataSource, ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return products.numberOfObjectsInSection(section)
    }

    func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
        return headerTextCellNode
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return products.numberOfSections()
    }

    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { [unowned self] _ in
            let cellNode = ProductCellNode(product: self.products[indexPath.row])
            cellNode.delegate = self
            return cellNode
        }
    }
}

extension ProductsViewController: ListSectionObserver {

    func listMonitorWillChange(_ monitor: ListMonitor<ProductEntity>) {
        collectionNode.view.beginUpdates()
    }

    func listMonitorDidChange(_ monitor: ListMonitor<ProductEntity>) {
        collectionNode.view.endUpdates(animated: true)
    }

    func listMonitorWillRefetch(_ monitor: ListMonitor<ProductEntity>) {
        setCollectionEnabled(false)
    }

    func listMonitorDidRefetch(_ monitor: ListMonitor<ProductEntity>) {
        collectionNode.reloadData()
        setCollectionEnabled(true)
    }

    func listMonitor(_ monitor: ListMonitor<ProductEntity>, didInsertObject object: ProductEntity, toIndexPath indexPath: IndexPath) {

        self.collectionNode.insertItems(at: [indexPath])
    }

    func listMonitor(_ monitor: ListMonitor<ProductEntity>, didDeleteObject object: ProductEntity, fromIndexPath indexPath: IndexPath) {

        self.collectionNode.deleteItems(at: [indexPath])
    }

    func listMonitor(_ monitor: ListMonitor<ProductEntity>, didUpdateObject object: ProductEntity, atIndexPath indexPath: IndexPath) {

        if let cell = self.collectionNode.nodeForItem(at: indexPath) as? ProductCellNode {
            cell.product = products[indexPath.row]
        }
    }

    func listMonitor(_ monitor: ListMonitor<ProductEntity>, didMoveObject object: ProductEntity, fromIndexPath: IndexPath, toIndexPath: IndexPath) {

        self.collectionNode.deleteItems(at: [fromIndexPath])
        self.collectionNode.insertItems(at: [toIndexPath])
    }

    // MARK: ListSectionObserver

    func listMonitor(_ monitor: ListMonitor<ProductEntity>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {

        self.collectionNode.insertSections(IndexSet(integer: sectionIndex))
    }

    func listMonitor(_ monitor: ListMonitor<ProductEntity>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {

        self.collectionNode.deleteSections(IndexSet(integer: sectionIndex))
    }
}

extension ProductsViewController: ProductsMosaicCollectionViewLayoutDelegate {
    internal func collectionView(_ collectionView: UICollectionView, layout: ProductsMosaicCollectionViewLayout, originalImageSizeAtIndexPath: IndexPath) -> CGSize {
        return products.objectsInSection(originalImageSizeAtIndexPath.section)[originalImageSizeAtIndexPath.item].imageSize ?? CGSize.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout: ProductsMosaicCollectionViewLayout, heightForTitleAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
        let name = products.objectsInSection(indexPath.section)[indexPath.row].name

        return name.calculateHeight(attributes: titleStringAttrs, width: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout: ProductsMosaicCollectionViewLayout, heightForSubtitleAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat? {
        guard let subheading = products.objectsInSection(indexPath.section)[indexPath.row].subheading else {
            return nil
        }

        return subheading.calculateHeight(attributes: subtitleStringAttrs, width: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout: ProductsMosaicCollectionViewLayout, heightForPricingAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
        let pricing = products.objectsInSection(indexPath.section)[indexPath.row].pricing

        var height: CGFloat = 0
        var rowHeight: CGFloat = 0

        for price in pricing {
            let priceStringSize = price.formattedValue.boundingRect(attributes: priceStringAttrs, width: width / 2)
            let priceButtonSize = CGSize(width: priceStringSize.width + priceButtonContentInsets.left + priceButtonContentInsets.right + priceButtonInsets.left + priceButtonInsets.right, height: priceStringSize.height + priceButtonContentInsets.top + priceButtonContentInsets.bottom + priceButtonInsets.top + priceButtonInsets.bottom)

            var modifierLabelHeight: CGFloat = 0
            if let modifierName = price.modifierName {
                let modifierStringHeight = modifierName.calculateHeight(attributes: modifierStringAttrs, width: width - priceButtonSize.width)
                modifierLabelHeight = modifierInsets.top + modifierStringHeight + modifierInsets.bottom
            }

            rowHeight = (modifierLabelHeight > priceButtonSize.height ?
                    modifierLabelHeight : priceButtonSize.height)

            height += rowHeight + (height == 0 ? 0 : Constants.ProductCellLayout.PricingRowSpacing)
        }

        return height + pricingInsets.bottom + cellInsets.bottom

    }
}

//extension ProductsViewController: ProductsMosaicLayoutDelegate {
//    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
//        guard let imageSize = products[indexPath.item].imageSize else {
//            return cellInsets.top
//        }
//
//        if imageSize.width < width {
//            print("LESS")
//        }
//        
//        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
//        let rect = AVMakeRect(aspectRatio: imageSize, insideRect: boundingRect)
//
//        return cellInsets.top + rect.size.height
//    }
//
//    func collectionView(_ collectionView: UICollectionView, heightForTitleAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
//        let title = products[indexPath.item].title
//        let maxWidth = width - (cellInsets.left + cellInsets.right + titleLabelInsets.left + titleLabelInsets.right)
//
//        return title.computeHeight(attributes: titleStringAttrs, width: maxWidth) +
//                titleLabelInsets.top + titleLabelInsets.bottom
//    }
//
//    func collectionView(_ collectionView: UICollectionView, heightForSubtitleAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
//        guard let subtitle = products[indexPath.item].subtitle else {
//            return 0
//        }
//
//        let maxWidth = width - (cellInsets.left + cellInsets.right + subtitleLabelInsets.left + subtitleLabelInsets.right)
//
//        return subtitle.computeHeight(attributes: subtitleStringAttrs, width: maxWidth) +
//                subtitleLabelInsets.top + subtitleLabelInsets.bottom
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, heightForPricingAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
//        let pricing = products[indexPath.item].pricing
//        
//        let maxWidth = width - (cellInsets.left + cellInsets.right + pricingInsets.left + pricingInsets.right)
//        var height:CGFloat = 0
//        var rowHeight: CGFloat = 0
//        
//        for price in pricing {
//            let priceStringSize = price.formattedValue.boundingRect(attributes: priceStringAttrs, width: maxWidth)
//            let priceButtonSize = CGSize(width: priceStringSize.width + priceButtonContentInsets.left + priceButtonContentInsets.right + priceButtonInsets.left + priceButtonInsets.right,
//                                         height: priceStringSize.height + priceButtonContentInsets.top + priceButtonContentInsets.bottom + priceButtonInsets.top + priceButtonInsets.bottom)
//            
//            var modifierLabelHeight:CGFloat = 0
//            if let modifierName = price.modifierName {
//                let modifierStringHeight = modifierName.computeHeight(attributes: modifierStringAttrs, width: maxWidth - priceButtonSize.width)
//                modifierLabelHeight = modifierInsets.top + modifierStringHeight + modifierInsets.bottom
//            }
//            
//            rowHeight = (modifierLabelHeight > priceButtonSize.height ?
//                modifierLabelHeight: priceButtonSize.height)
//            
//            height = height + rowHeight + (height == 0 ? 0 : Constants.ProductCellLayout.PricingRowSpacing)
//        }
//        
//        return pricingInsets.top + height + pricingInsets.bottom + cellInsets.bottom
//    }
//}
