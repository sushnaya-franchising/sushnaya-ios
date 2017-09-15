import Foundation
import AsyncDisplayKit
import CoreStore


class CategoriesViewController: ASViewController<ASDisplayNode>, PaperFoldAsyncView {

    let cellInsets = Constants.DefaultCellLayout.CellInsets    
    let titleStringAttrs = Constants.DefaultCellLayout.TitleStringAttributes
    let imageSize = Constants.DefaultCellLayout.ImageSize

    var categories: ListMonitor<MenuCategoryEntity> {
        return app.core.categories
    }
    
    fileprivate var collectionNode: ASCollectionNode!
    
    var onViewUpdated: (() -> ())?    
    
    convenience init() {
        self.init(node: ASDisplayNode())
        
        let layout = UICollectionViewFlowLayout()
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        
        setupTableNode()
        
        node.automaticallyManagesSubnodes = true
        node.backgroundColor = PaperColor.White
        node.layoutSpecBlock = { [unowned self] _ in
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0), child: self.collectionNode)
        }
        
        categories.addObserver(self)
    }
    
    deinit {
        EventBus.unregister(self)
        categories.removeObserver(self)
    }
    
    private func setupTableNode() {
        collectionNode.delegate = self
        collectionNode.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionNode.view.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 49 + 10, right: 0)
        collectionNode.view.showsVerticalScrollIndicator = false                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onViewUpdated?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    fileprivate func setCollectionEnabled(_ enabled: Bool) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .beginFromCurrentState,
            animations: { [unowned self] () -> Void in
                self.collectionNode.alpha = enabled ? 1.0 : 0.5
                self.collectionNode.isUserInteractionEnabled = enabled
        },
            completion: nil
        )
    }
}

extension CategoriesViewController: ListSectionObserver {
    
    func listMonitorWillChange(_ monitor: ListMonitor<MenuCategoryEntity>) {
        collectionNode.view.beginUpdates()
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<MenuCategoryEntity>) {
        collectionNode.view.endUpdates(animated: true)
    }
    
    func listMonitorWillRefetch(_ monitor: ListMonitor<MenuCategoryEntity>) {
        setCollectionEnabled(false)
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<MenuCategoryEntity>) {
        collectionNode.reloadData()
        setCollectionEnabled(true)
    }
    
    func listMonitor(_ monitor: ListMonitor<MenuCategoryEntity>, didInsertObject object: MenuCategoryEntity, toIndexPath indexPath: IndexPath) {
        
        self.collectionNode.insertItems(at: [indexPath])
    }
    
    func listMonitor(_ monitor: ListMonitor<MenuCategoryEntity>, didDeleteObject object: MenuCategoryEntity, fromIndexPath indexPath: IndexPath) {
        
        self.collectionNode.deleteItems(at: [indexPath])
    }
    
    func listMonitor(_ monitor: ListMonitor<MenuCategoryEntity>, didUpdateObject object: MenuCategoryEntity, atIndexPath indexPath: IndexPath) {
        
        if let cell = self.collectionNode.nodeForItem(at: indexPath) as? DefaultCellNode {
            cell.context = CategoryCellContext(categories[indexPath])
        }
    }
    
    func listMonitor(_ monitor: ListMonitor<MenuCategoryEntity>, didMoveObject object: MenuCategoryEntity, fromIndexPath: IndexPath, toIndexPath: IndexPath) {

        self.collectionNode.deleteItems(at: [fromIndexPath])
        self.collectionNode.insertItems(at: [toIndexPath])
    }
    
    // MARK: ListSectionObserver
    
    func listMonitor(_ monitor: ListMonitor<MenuCategoryEntity>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        self.collectionNode.insertSections(IndexSet(integer: sectionIndex))
    }

    func listMonitor(_ monitor: ListMonitor<MenuCategoryEntity>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {

        self.collectionNode.deleteSections(IndexSet(integer: sectionIndex))
    }
}

extension CategoriesViewController: ASCollectionDelegate, ASCollectionDataSource {
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        return categories.numberOfObjectsInSection(section)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return categories.numberOfSections()
    }    
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return { [unowned self] _ in
            DefaultCellNode(context: CategoryCellContext(self.categories[indexPath.row]))
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let category = categories.objectsInSection(indexPath.section)[indexPath.row]
        
        DidSelectCategoryEvent.fire(category: category)
        
        FoodServiceRest.requestProducts(categoryId: category.serverId, authToken: app.authToken!)
    }
}

class CategoryCellContext: DefaultCellContext {
    override var title: String {
        set {
            category.name = newValue
        }
        
        get {
            return category.name
        }
    }
    
    override var imageSize: CGSize? {
        set {            
            category.imageSize = newValue
        }
        
        get{
            return category.imageSize
        }
    }
    
    override var imageUrl: String? {
        set {
            category.imageUrl = newValue
        }
        
        get {
            return category.imageUrl
        }
    }
    
    var category: MenuCategoryEntity
    
    init(_ category: MenuCategoryEntity) {
        self.category = category
        
        super.init(title: category.name)
        
        if let imageSize = category.imageSize {
            self.preferredImageSize = CGSize(width: 64, height: imageSize.height / (imageSize.width / 64))                        
        }                
    }
}
