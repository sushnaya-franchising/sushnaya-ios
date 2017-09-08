import Foundation
import AsyncDisplayKit
import CoreStore


class CategoriesViewController: ASViewController<ASDisplayNode>, PaperFoldAsyncView {

    let cellInsets = Constants.DefaultCellLayout.CellInsets    
    let titleStringAttrs = Constants.DefaultCellLayout.TitleStringAttributes
    let imageSize = Constants.DefaultCellLayout.ImageSize

    fileprivate var collectionNode: ASCollectionNode!
    
    var onViewUpdated: (() -> ())?

    fileprivate var categories: ListMonitor<MenuCategoryEntity>?
    
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
        
        EventBus.onMainThread(self, name: DidSelectMenuEvent.name) { [unowned self] (notification) in
            self.setupCategoriesMonitor()
        }
    }
    
    deinit {
        EventBus.unregister(self)
    }
    
    private func setupTableNode() {
        collectionNode.delegate = self
        collectionNode.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionNode.view.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 49 + 10, right: 0)
        collectionNode.view.showsVerticalScrollIndicator = false
        
        setupCategoriesMonitor()
    }
    
    func setupCategoriesMonitor() {
        guard let menu = self.app.userSession.settings.menu else { return }
        
        self.categories?.removeObserver(self)
        
        self.categories = CoreStore.monitorList(From<MenuCategoryEntity>(), Where("menu.serverId", isEqualTo: menu.serverId), OrderBy(.ascending("title")))
        
        self.categories?.addObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupCategoriesMonitor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)                
    }
}

extension CategoriesViewController: ListSectionObserver {
    
    func listMonitorWillChange(_ monitor: ListMonitor<MenuCategoryEntity>) { }
    
    func listMonitorDidChange(_ monitor: ListMonitor<MenuCategoryEntity>) {
        collectionNode.reloadData()
    }
    
    func listMonitorWillRefetch(_ monitor: ListMonitor<MenuCategoryEntity>) { }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<MenuCategoryEntity>) { }
    
    func listMonitor(_ monitor: ListMonitor<MenuCategoryEntity>, didInsertObject object: MenuCategoryEntity, toIndexPath indexPath: IndexPath) {
        
        self.collectionNode.insertItems(at: [indexPath])
    }
    
    func listMonitor(_ monitor: ListMonitor<MenuCategoryEntity>, didDeleteObject object: MenuCategoryEntity, fromIndexPath indexPath: IndexPath) {
        
        self.collectionNode.deleteItems(at: [indexPath])
    }
    
    func listMonitor(_ monitor: ListMonitor<MenuCategoryEntity>, didUpdateObject object: MenuCategoryEntity, atIndexPath indexPath: IndexPath) {
        
        if let cell = self.collectionNode.nodeForItem(at: indexPath) as? DefaultCellNode {
            cell.context = CategoryCellContext(categories![indexPath])
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
        
        return categories?.numberOfObjectsInSection(section) ?? 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return categories?.numberOfSections() ?? 0
    }    
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard let categoryEntity = categories?[indexPath.row] else {
            return { ASCellNode() }
        }
        
        return { DefaultCellNode(context: CategoryCellContext(categoryEntity)) }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didEndDisplayingItemWith node: ASCellNode) {
        onViewUpdated?()
    }
}

class CategoryCellContext: DefaultCellContext {
    override var title: String {
        set {
            category.title = newValue
        }
        
        get {
            return category.title
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
        
        super.init(title: category.title)
        
        if let imageSize = category.imageSize {
            self.preferredImageSize = CGSize(width: 64, height: imageSize.height / (imageSize.width / 64))
        }                
    }
}
